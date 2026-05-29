# Color

> Load before applying any color in a widget.

---

## The rule in one line

```dart
final colors = Theme.of(context).extension<ColorScale>()!;
// Then: colors.backgroundPrimary, colors.contentPrimary, etc.
```

Never hardcode hex. Never use `Colors.*`. Never import `ColorPrimitives` in a widget.

---

## Token groups

### Brand — primary interactive colors

| Token | Hex | Use when |
|---|---|---|
| `brandPrimary` | #CE3E00 | Primary CTA, active indicator, brand moment, progress fill |
| `brandDark` | #031223 | Alternate primary CTA on light backgrounds, high-contrast surface |

**When to choose `brandPrimary` vs `brandDark`:**
- `brandPrimary` (orange) — the default primary action. One per screen.
- `brandDark` (navy) — alternate when the screen already has a brandPrimary element, or when the surface is warm-toned and orange clashes.
- Never use both on the same interactive element.

---

### Feedback — status communication

| Token | Hex | Use when |
|---|---|---|
| `feedbackNegative` | #F5222D | Error state, destructive action, failed transaction, form validation failure |
| `feedbackWarning` | #FAAD14 | Caution, pending approval, expiry warning, review required |
| `feedbackPositive` | #52C41A | Success, confirmed, approved, completed action |

**Rules for feedback colors:**
- Use as icon color, text color, or border color directly.
- For a tinted surface (e.g. an alert banner), pair with `backgroundSecondary` or use `.withAlpha()` at 10–15% — never as a full background fill.
- Never use feedback colors for decorative purposes — they carry meaning.
- State must never be conveyed by color alone — always pair with an icon or text label.

---

### Surface › Background — container and page fills

| Token | Hex | Use when | Do NOT use for |
|---|---|---|---|
| `backgroundPrimary` | #FFFFFF | Default page background, card surface, modal surface, text on dark fills | Never as text color |
| `backgroundSecondary` | #F1F6FB | Alternate row, section divider, recessed panel, skeleton loader | First-level card on white page |
| `backgroundTertiary` | #E1EAF4 | Disabled fill, subtle wash, chip background, tag background | Any interactive element in active state |

**Depth model:**
```
Page → backgroundPrimary
  Card on page → backgroundSecondary
    Recessed element in card → backgroundTertiary
```
Never jump levels (e.g. backgroundTertiary directly on a backgroundPrimary page) unless creating explicit depth contrast.

---

### Surface › Content — text and icon colors

| Token | Hex | Use when | Do NOT use for |
|---|---|---|---|
| `contentPrimary` | #121212 | Default body copy, headings, labels, icons — start here | Placeholder text, disabled text |
| `contentSecondary` | #4B545E | Supporting text — captions, subtitles, helper lines, secondary labels | Primary body copy |
| `contentTertiary` | #BBC9D9 | Disabled text, placeholder, de-emphasised metadata | Any interactive or readable text |

**Choosing content depth:**
- Default: `contentPrimary`. Everything starts here.
- One hierarchy level back: `contentSecondary`. Use for supporting context the user needs but doesn't read first.
- Structural placeholder only: `contentTertiary`. If the user needs to act on the text, it should not be tertiary.

---

### Surface › Border — strokes and dividers

| Token | Hex | Use when |
|---|---|---|
| `borderOpaque` | #E1EAF4 | Default card outline, input idle state border, list divider, separator |
| `borderSelection` | #121212 | Selected state, focused input border, active toggle border |

---

## Pairing rules

| Surface fill | Text / icon color | Reason |
|---|---|---|
| `brandPrimary` (orange) | `backgroundPrimary` (white) | `contentPrimary` on orange fails WCAG AA |
| `brandDark` (navy) | `backgroundPrimary` (white) | Dark navy requires white to pass contrast |
| `backgroundPrimary` (white) | `contentPrimary` | Default — always start here |
| `backgroundSecondary` | `contentPrimary` or `contentSecondary` | Both pass contrast on this surface |
| `backgroundTertiary` | `contentTertiary` | **Disabled pairing only** — do not use for readable content |
| `feedbackNegative/Warning/Positive` | `backgroundPrimary` if used as fill | Feedback as full fill needs white text |

---

## Interactive states

When a component changes state, change both fill and content — never color alone:

| State | Fill | Text / Icon | Border |
|---|---|---|---|
| Default | `backgroundPrimary` | `contentPrimary` | `borderOpaque` |
| Active / Selected | `brandPrimary` | `backgroundPrimary` | — |
| Disabled | `backgroundTertiary` | `contentTertiary` | `borderOpaque` |
| Error | `backgroundPrimary` | `feedbackNegative` | `feedbackNegative` |
| Focus | `backgroundPrimary` | `contentPrimary` | `borderSelection` |

---

## Known gaps (no Tier 2 alias yet)

These hex values appear in product designs but have no semantic Tier 2 token. When encountered, use the documented workaround and leave a `// Gap:` comment.

| Figma value | What it is | Workaround | When to add a token |
|---|---|---|---|
| `#262B30` | neutralGrey800 — high-emphasis text | `colors.contentPrimary` (#121212) | When a third content depth is needed consistently |
| `#8C9AAA` | neutralGrey600 — low-emphasis text | `colors.contentSecondary` (#4B545E) | When mid-tone text appears in 3+ components |
| `#389E0D` | successGreen500 — stronger positive | `colors.feedbackPositive` (#52C41A) | When positive emphasis needs two levels |
| `#D48806` | alertYellow500 — deeper warning | `colors.feedbackWarning` (#FAAD14) | When warning has two emphasis levels |
| `#FFF2EC` | primaryScapia000 — orange tint bg | `ColorPrimitives.primaryScapia000` | When orange tinted backgrounds are a pattern |
| `rgba(0,0,0,0.4)` | Image overlay | `const Color(0x66000000)` | When overlay opacity becomes a token |

---

## Theme-switching contract

`ColorScale` is a `ThemeExtension<T>`. Swapping light → dark → seasonal changes the extension instance — zero widget code changes. This is why `ColorPrimitives` must never appear in widgets: primitives don't theme-switch, `ColorScale` fields do.

```dart
// ScapiaTheme wires it — widgets are theme-agnostic
extensions: [ColorScale.light],  // swap to ColorScale.dark when dark mode ships
```

---

## DO / DON'T

```dart
// DO
final colors = Theme.of(context).extension<ColorScale>()!;
DecoratedBox(
  decoration: BoxDecoration(
    color: colors.backgroundPrimary,
    border: Border.all(color: colors.borderOpaque),
  ),
)

// DON'T — hardcoded hex
Container(color: const Color(0xFFFFFFFF))

// DON'T — Flutter built-in
Container(color: Colors.white)

// DON'T — reaching into Tier 1
Container(color: ColorPrimitives.neutralGrey000)

// DON'T — ThemeData.colorScheme for semantic colors
Container(color: Theme.of(context).colorScheme.surface)
```

---

## What NOT to use

- `Colors.*` — banned entirely. No `Colors.white`, `Colors.black`, `Colors.grey`, `Colors.transparent`.
- `Color(0xFF...)` literals in widget files — banned.
- `ColorPrimitives.*` in widget files — Tier 1 is for token tests and Tier 2 internal implementation only.
- `ThemeData.colorScheme` for semantic colors — use `ColorScale` instead. `colorScheme` is only for Material system components that require it.
- Opacity-modified brand colors for backgrounds (e.g. `brandPrimary.withAlpha(20)`) — only acceptable as a documented gap workaround, never as a design choice.
