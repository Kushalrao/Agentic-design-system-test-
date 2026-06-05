# Seasonal DLS — Agentic Design System

An AI-first Flutter design system where components are implemented end-to-end by Claude using a structured skill procedure, not written by hand. Every widget is derived directly from Figma data — dimensions read from MCP responses, tokens resolved from registered Figma variables, icons exported from the Figma library.

---

## What this is

This repo is a proof of concept for **agentic design system implementation**: a Flutter DS where an AI agent (Claude Code) builds production-quality components from Figma links, enforcing a strict process that eliminates the most common sources of drift between design and code.

**Key principle:** The agent never estimates, never guesses, never rounds. Every value in the code traces to a specific field in a specific Figma MCP response.

---

## Stack

| Layer | Technology |
|---|---|
| UI framework | Flutter (Dart) |
| Monorepo | Melos workspace |
| Design source | Figma (Seasonal DLS file) |
| Agent | Claude Code (claude-sonnet-4-6) |
| Design → code bridge | Figma MCP (REST) + figma-console MCP (Desktop Bridge) |
| DS knowledge server | Custom MCP (`tools/ds-mcp/`) |
| Component catalog | Widgetbook 3.x |
| Icon format | SVG via `flutter_svg ^2.0.10` |
| Linting | Custom DS lint scanner + `flutter_lints` |

---

## Repository structure

```
packages/
  tokens/          Three-tier token system (source of truth for all values)
    lib/src/
      color_primitives.dart   Tier 1 — 60 raw hex colors
      foundation.dart         Tier 1 — font families, sizes, weights, line heights
      spacing_primitives.dart Tier 1 — raw dp values
      radius_tokens.dart      Tier 1 — named radii r4→r44, full
      opacity_tokens.dart     Tier 1 — opacity0→opacity100
      color_scale.dart        Tier 2 — ColorScale ThemeExtension (13 semantic fields)
      typography_scale.dart   Tier 2 — 22 TextStyle statics matching Figma names
      spacing_scale.dart      Tier 2 — SpacingScale (17 named gaps)
      button_tokens.dart      Tier 3 — ButtonTokens (4 context functions)

  ds/
    lib/src/
      components/
        button/     DsButton
        rating/     DsScapiaScore, DsStayStars
        stays/      StaysSrpCard, StaysPropertyCard
      icons/
        scapia_icons.dart     13,751 icon constants (generated)
    assets/
      icons/        13,751 SVG files across 51 categories
      fonts/        Lexend Deca, GT Ultra Median Trial, GT Flaire Basic Trial
    figma/          Code Connect definition files (*.figma.js)
    widgetbook/     Interactive component catalog

apps/
  app/             Product app (depends on packages/ds)

tools/
  lint/
    check_ds_rules.dart     DS token tier contract scanner (6 rules)
  export_icons.py           Bulk SVG export from Figma Iconography page
  tokens/                   Figma → Dart token pipeline
  ds-mcp/                   DS knowledge MCP server

knowledgebase/
  foundations/
    color.md        Semantic color intent, pairing rules, depth model
    typography.md   Type hierarchy, when to use each style
    spacing.md      Composition recipes, token selection guidance
    quality.md      Widget authoring checklist (30+ checks)
    icons.md        Icon library, naming convention, flutter_svg constraints
  components/       Per-component API contract + token usage + gaps
  ds-playbook.md    Complete system reference
  decisions/        Architectural decision records

.claude/
  commands/
    implement-figma-component.md   9-phase skill (26 failure modes documented)
```

---

## Token architecture

Three tiers, strict rules about which tier widgets can touch:

```
Tier 1 — Primitives (never used in widgets)
  ColorPrimitives.neutralGrey600   → raw hex #8C9AAA
  Foundation.fontSize15            → raw double 15.0
  SpacingPrimitives.spacing21      → raw double 21.0

Tier 2 — Semantic aliases (what every widget uses)
  colors.contentSecondary          → ColorPrimitives.neutralGrey600
  TypographyScale.pMedium          → TextStyle(size:15, w400, lh23, Lexend Deca)
  SpacingScale.spaceXl             → SpacingPrimitives.spacing21

Tier 3 — Component tokens (context-dependent)
  ButtonTokens.primaryOrangeBackground(context)  → colors.brandPrimary
```

The alias chain mirrors Figma's variable collections exactly. `melos run tokens` regenerates Tier 1 from the Figma snapshot.

---

## Components

| Component | File | Figma source | Variants |
|---|---|---|---|
| `DsButton` | `button/ds_button.dart` | Seasonal DLS | 3 variants × 3 states |
| `DsScapiaScore` | `rating/ds_scapia_score.dart` | Seasonal DLS | With label / without label |
| `DsStayStars` | `rating/ds_stay_stars.dart` | Seasonal DLS | starCount (1–5) + optional label |

---

## Icon library

**13,751 SVG icons** exported from the Figma Seasonal DLS Iconography page across 51 categories.

```dart
// Usage — always use ScapiaIcons constants, never raw strings
SvgPicture.asset(
  ScapiaIcons.hotelsKitchen25px,
  width: 25,
  height: 25,
  colorFilter: ColorFilter.mode(colors.contentSecondary, BlendMode.srcIn),
)
```

Naming convention: `{category-slug}/{keywords-slug}_{size}px.svg`
Example: `Hotels/kitchen/ 25px` → `ScapiaIcons.hotelsKitchen25px`

To re-export after Figma Iconography changes:
```bash
FIGMA_ACCESS_TOKEN=your_token melos run icons:export
```

---

## Figma setup (one-time, already done)

**Code syntax registered on 55 Figma variables** (Spacing, Radius, Opacity, Color Semantics, Button collections). Platform: Android. This makes the Figma MCP send `SpacingScale.spaceLg` instead of `15 dp` to the agent — eliminating the entire token lookup step for most values.

**Code Connect published** for all components — Dart snippets appear in Figma Dev Mode when a component is inspected.

---

## MCP servers

Three MCP servers power the agentic workflow:

| Server | Role | Key tools |
|---|---|---|
| `ds` (custom) | DS knowledge — tokens, components, gaps | `list_components`, `check_token`, `get_typography_style`, `get_spacing_recipe` |
| `figma` (REST) | Figma design data | `get_design_context`, `get_context_for_code_connect`, `get_screenshot` |
| `figma-console` (Desktop Bridge) | Live Figma data | `figma_get_text_styles`, `figma_get_variables`, `figma_execute` |

The Desktop Bridge (`figma-console`) requires Figma Desktop open with the Desktop Bridge plugin running. It is the preferred source for text styles and variables — the skill hard-blocks if it returns empty.

---

## The implementation skill

Invoking `/implement-figma-component <figma-url>` runs a 9-phase procedure:

| Phase | What it does |
|---|---|
| 0 | Load all foundation files + token state |
| 0.5 | Reuse check — `list_components()` + `get_code_connect_map` |
| 1 | Fetch text styles (hard block if empty) |
| 2 | Fetch variables + resolve to Dart tokens (hard block if empty) |
| 2.5 | Classify node (Static Frame / Component With Properties) + nested INSTANCE traversal |
| 2.6 | Variant matrix — fetch all variant node IDs from COMPONENT_SET *(if applicable)* |
| 2.75 | Pre-flight: scope, state completeness, StatelessWidget vs StatefulWidget |
| 3 | Fetch design context → exhaustive node inventory (22 columns per frame) |
| 3.5 | Map all layout fields to Flutter equivalents (7 lookup tables) |
| 4 | Token mapping table with EXACT / NEAREST / NONE classification + batch gap review |
| 5 | Write widget (derived from tables only, no visual guessing) |
| 6 | 4-gate validation: `dart analyze` → DS lint → token tests → golden regression |
| 7 | Knowledgebase doc |
| 8 | Golden tests + visual comparison |
| 9 | Code Connect publish |

**26 documented failure modes** are enforced at their specific phase — from estimated dimensions to silent nearest-token rounding to ignored nested INSTANCE properties.

---

## DS lint scanner

```bash
dart tools/lint/check_ds_rules.dart
```

6 rules enforced in CI:

| Rule | What it catches |
|---|---|
| `no_hardcoded_color` | `Color(0xFF...)` literals |
| `no_flutter_colors` | `Colors.*` usage |
| `no_tier1_in_widgets` | `ColorPrimitives.*`, `Foundation.*` in widget files |
| `no_inline_text_style` | `TextStyle(fontSize: N)` raw assembly |
| `no_bare_border` | `Border.all(color:)` without explicit `width:` |
| `no_raw_spacing_literal` | `SizedBox`/`EdgeInsets` with a raw number matching a SpacingScale value |

---

## Commands

```bash
# Setup
flutter pub get                           # Install dependencies

# Development
melos run widgetbook                      # Launch Widgetbook catalog in Chrome

# Token pipeline
melos run tokens                          # Figma snapshot → Dart token files
melos run ds-mcp:generate                 # Regenerate DS MCP snapshot

# Icon pipeline
FIGMA_ACCESS_TOKEN=xxx melos run icons:export   # Re-export all icons from Figma

# Validation
dart analyze packages/ apps/              # Full workspace lint
dart tools/lint/check_ds_rules.dart       # DS token tier rules
flutter test packages/tokens/            # Token alias chain + tier contract
melos run test:goldens                    # All golden tests (regression)

# Golden management
flutter test packages/ds/test/components/{dir}/ --update-goldens   # Regenerate

# Code Connect
melos run code-connect:check              # Validate without publishing
melos run code-connect:publish            # Publish to Figma Dev Mode (needs FIGMA_ACCESS_TOKEN)
```

---

## Known gaps

| Gap | Impact | Plan |
|---|---|---|
| Both `StaysSrpCard` + `StaysPropertyCard` are static frames (no Figma component properties) | Code Connect snippets are static | Add component properties in Figma → dynamic wiring becomes possible |
| `Border/1`, `Border/2` — no Dart token class | Raw `1.0`/`2.0` with gap comments | Create `BorderTokens` when a third component uses these |
| `Spacing/17` — no `SpacingScale` token | Documented as NONE gap | Add token if it appears in 3+ components |
| Figma-to-live visual comparison | No automated pixel-diff between Figma frames and running app | Applitools is the only verified solution; manual review today |
| `get_variable_defs` returns default mode only | Light mode values only | Affects future dark mode implementation |
| Color token accuracy not auto-validated | Wrong primitive reference could ship silently | Add validation script to `melos run tokens` pipeline (planned) |

---

## Process improvements applied

Throughout building this system, several process improvements were discovered and applied:

- **Node inventory tables** — every MCP-returned field gets a verbatim table cell before any code is written
- **Gap ownership** — every spacing gap traced to its direct parent frame's `itemSpacing`, not assumed
- **Match-type column** — EXACT / NEAREST / NONE forces explicit decisions on every token mapping
- **Nested INSTANCE traversal** — icon names read from Figma VARIANT options, never guessed visually
- **Variant matrix** — COMPONENT WITH PROPERTIES fetches all variant node IDs before Phase 3
- **Hard blocks** — skill stops if `figma_get_text_styles` or `figma_get_variables` returns empty
- **Batch gap protocol** — all unknown gaps collected, presented once, resolved before any code is written
- **SVG sanitization** — `style="..."` CSS attributes stripped from all exported SVGs (`mix-blend-mode` causes silent blank render in `flutter_svg` on Flutter web)
- **Explicit pubspec subdirectory declarations** — Flutter web dev server requires each `assets/icons/{category}/` listed explicitly; automated in `export_icons.py`
