#!/usr/bin/env python3
"""
Export all Figma icons from Seasonal DLS Iconography page to packages/ds/assets/icons/
and generate ScapiaIcons dart class.

Usage:
  FIGMA_ACCESS_TOKEN=your_token python3 tools/export_icons.py
"""
import json, re, os, unicodedata, time, urllib.request, sys
from concurrent.futures import ThreadPoolExecutor, as_completed

TOKEN     = os.environ.get("FIGMA_ACCESS_TOKEN", "")
FILE_KEY  = "FNq7xbMPO5wM5mM4EOo2hY"
ASSETS_DIR = "packages/ds/assets/icons"
DART_FILE  = "packages/ds/lib/src/icons/scapia_icons.dart"
XML_CACHE  = "/Users/kushalyadav/.claude/projects/-Users-kushalyadav-Downloads-ds-trial/43b8e7d0-0073-4524-9018-552b96b482cf/tool-results/mcp-figma-get_metadata-1780652290708.txt"
PARALLEL   = 50  # concurrent SVG downloads

if not TOKEN:
    print("ERROR: set FIGMA_ACCESS_TOKEN env var", file=sys.stderr)
    sys.exit(1)

HEADERS = {"X-Figma-Token": TOKEN}

def slugify(s):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
    s = s.lower().strip()
    s = re.sub(r",\s*", "-", s)
    s = re.sub(r"\s+", "-", s)
    s = re.sub(r"[^a-z0-9\-]", "", s)
    return re.sub(r"-+", "-", s).strip("-")

def camelcase(slug):
    parts = slug.split("-")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])

def derive(name):
    parts = [p.strip() for p in name.split("/") if p.strip()]
    if len(parts) < 2: return None
    m = re.search(r"(\d+)px", parts[-1])
    if not m: return None
    size = m.group(1)
    cat  = slugify(parts[0])
    kw   = slugify(" ".join(parts[1:-1]))
    if not cat: return None
    # 2-part names (e.g. "Scapia score/ 11px") have no keyword segment.
    # Use the category slug as the keyword so they are not silently skipped.
    if not kw:
        kw = cat
    fp = f"{cat}/{kw}_{size}px.svg"
    dc = camelcase(f"{cat}-{kw}-{size}px")
    return {"fp": fp, "dc": dc, "cat": cat}


def sanitize_svg(content: bytes) -> bytes:
    """Strip inline CSS style attributes that flutter_svg / vector_graphics
    does not support (mix-blend-mode, filter, isolation, etc.).
    flutter_svg reads SVG presentation attributes directly; CSS inline styles
    are silently ignored or cause the entire render to fail on Flutter web.
    """
    text = content.decode("utf-8", errors="replace")
    # Remove style="..." attributes wholesale — they carry only CSS properties
    # that vector_graphics cannot render. Opacity, fill, stroke etc. are always
    # set as proper SVG presentation attributes by Figma alongside the style.
    text = re.sub(r'\s+style="[^"]*"', "", text)
    return text.encode("utf-8")

def download_svg(item):
    """Download one SVG and write it. Returns (fp, success)."""
    svg_url, fp = item
    dest = os.path.join(ASSETS_DIR, fp)
    # Skip if already downloaded
    if os.path.exists(dest):
        return fp, True
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        with urllib.request.urlopen(svg_url, timeout=20) as r:
            content = r.read()
        with open(dest, "wb") as f:
            f.write(sanitize_svg(content))
        return fp, True
    except Exception:
        return fp, False

def main():
    # ── 1. Parse metadata ─────────────────────────────────────────────────
    print("Parsing metadata...", flush=True)
    with open(XML_CACHE) as f:
        raw = json.load(f)
    xml_text = raw[0]["text"]
    symbols = re.findall(r'<symbol id="([^"]+)" name="([^"]+)"', xml_text)
    print(f"  {len(symbols)} entries found", flush=True)

    seen, icons = set(), []
    for nid, name in symbols:
        info = derive(name)
        if not info or info["fp"] in seen: continue
        seen.add(info["fp"])
        icons.append({"id": nid, "name": name, **info})
    print(f"  {len(icons)} unique icons", flush=True)

    # Already downloaded check
    already = sum(1 for ic in icons if os.path.exists(os.path.join(ASSETS_DIR, ic["fp"])))
    print(f"  {already} already on disk, {len(icons)-already} to fetch", flush=True)

    # ── 2. Batch-fetch SVG URLs ───────────────────────────────────────────
    BATCH = 200
    all_urls = {}
    total_batches = (len(icons) + BATCH - 1) // BATCH
    print(f"Fetching SVG URLs ({total_batches} batches)...", flush=True)

    for i in range(0, len(icons), BATCH):
        batch = icons[i:i+BATCH]
        ids = ",".join(b["id"] for b in batch)
        url = f"https://api.figma.com/v1/images/{FILE_KEY}?ids={ids}&format=svg"
        req = urllib.request.Request(url, headers=HEADERS)
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                data = json.loads(r.read())
            imgs = data.get("images", {})
            for k, v in imgs.items():
                if v:
                    all_urls[k] = v
                    all_urls[k.replace("-", ":")] = v
                    all_urls[k.replace(":", "-")] = v
        except Exception as e:
            print(f"  Batch {i//BATCH+1} error: {e}", flush=True)
        bn = i // BATCH + 1
        if bn % 10 == 0:
            print(f"  {bn}/{total_batches} batches done", flush=True)
            time.sleep(0.2)

    print(f"  {len(all_urls)//3} valid URLs received", flush=True)

    # ── 3. Parallel download ──────────────────────────────────────────────
    tasks = []
    for icon in icons:
        svg_url = all_urls.get(icon["id"])
        if svg_url:
            tasks.append((svg_url, icon["fp"]))

    print(f"Downloading {len(tasks)} SVGs with {PARALLEL} parallel workers...", flush=True)
    written = failed = skipped = 0
    done = 0

    with ThreadPoolExecutor(max_workers=PARALLEL) as pool:
        futures = {pool.submit(download_svg, t): t for t in tasks}
        for future in as_completed(futures):
            fp, ok = future.result()
            done += 1
            if ok: written += 1
            else: failed += 1
            if done % 500 == 0:
                print(f"  {done}/{len(tasks)} done ({written} written, {failed} failed)", flush=True)

    print(f"  ✅ {written} written, {failed} failed", flush=True)

    # ── 4. Generate ScapiaIcons.dart ──────────────────────────────────────
    print("Generating ScapiaIcons.dart...", flush=True)
    by_cat = {}
    for icon in icons:
        dest = os.path.join(ASSETS_DIR, icon["fp"])
        if os.path.exists(dest):
            by_cat.setdefault(icon["cat"], []).append(icon)

    lines = [
        "// GENERATED — source of truth: Figma › Seasonal DLS › Iconography.",
        "// Do not edit manually. Re-run: python3 tools/export_icons.py",
        "// ignore_for_file: lines_longer_than_80_chars",
        "",
        "// Usage:",
        "//   import 'package:scapia_ds/scapia_ds.dart';",
        "//   SvgPicture.asset(ScapiaIcons.hotelsKitchen25px, width: 25, height: 25,",
        "//     colorFilter: ColorFilter.mode(colors.contentSecondary, BlendMode.srcIn))",
        "",
        "abstract final class ScapiaIcons {",
        "  static const String _base = 'packages/scapia_ds/assets/icons';",
    ]
    total_consts = 0
    for cat in sorted(by_cat):
        disp = cat.replace("-", " ").title()
        sep  = "─" * max(0, 58 - len(disp))
        lines.append("")
        lines.append(f"  // ── {disp} {sep}")
        for icon in sorted(by_cat[cat], key=lambda x: x["dc"]):
            fp = icon["fp"]
            dc = icon["dc"]
            lines.append(f"  /// Figma: {icon['name']}")
            lines.append("  static const String " + dc + " = '$_base/" + fp + "';")
            total_consts += 1
    lines.append("}")

    with open(DART_FILE, "w") as f:
        f.write("\n".join(lines) + "\n")

    total_files = sum(len(v) for v in by_cat.values())
    print(f"ScapiaIcons: {total_consts} constants in {len(by_cat)} categories", flush=True)

    # ── 5. Update pubspec asset declarations ──────────────────────────────────
    # Flutter web dev server requires each icon subdirectory to be explicitly
    # declared in pubspec.yaml — a trailing-slash parent declaration alone
    # does not reliably serve subdirectory assets in development mode.
    # This step keeps both pubspecs in sync automatically.
    print("Updating pubspec asset declarations...", flush=True)
    subdirs = sorted([
        d for d in os.listdir(ASSETS_DIR)
        if os.path.isdir(os.path.join(ASSETS_DIR, d))
    ])
    # Only update the DS package pubspec — widgetbook pubspec only declares
    # its own assets/icons/ (the scapia-score icon copy). The DS package's
    # explicit subdir declarations are what makes package assets resolvable
    # at packages/scapia_ds/assets/icons/... in Flutter web dev mode.
    for pubspec_path in ["packages/ds/pubspec.yaml"]:
        if not os.path.exists(pubspec_path):
            continue
        with open(pubspec_path) as f:
            content = f.read()
        lines_out = []
        for line in content.split("\n"):
            if re.match(r'\s+- assets/icons/\w', line):
                continue  # remove stale subdir declarations
            lines_out.append(line)
            if line.strip() == "- assets/icons/":
                for d in subdirs:
                    lines_out.append(f"    - assets/icons/{d}/")
        with open(pubspec_path, "w") as f:
            f.write("\n".join(lines_out))
        print(f"  {pubspec_path}: {len(subdirs)} subdirs declared", flush=True)
    print("  Run 'flutter pub get' in packages/ds/ and packages/ds/widgetbook/ to apply.", flush=True)

    print(f"\n✅ Done — {total_files} SVGs in packages/ds/assets/icons/", flush=True)

if __name__ == "__main__":
    main()
