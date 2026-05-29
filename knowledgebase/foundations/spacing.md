# Spacing

> Composition recipes — when and how to combine spacing tokens in layouts.
> Load this file before writing any widget layout code.

---

## The scale

All spacing comes from `SpacingScale`. Source of truth: Figma › Seasonal DLS › Containers › Spacing.

| Token | Value | Use when |
|---|---|---|
| `SpacingScale.spaceNone` | 0 dp | Explicitly zero — remove default padding/margin |
| `SpacingScale.space2xs` | 2 dp | Hairline gap, icon-to-badge nudge, pixel-level correction |
| `SpacingScale.spaceXs` | 5 dp | Tight icon-to-label gap, compact chip internal padding |
| `SpacingScale.spaceSm` | 7 dp | Internal padding for small components (tag, badge, chip) |
| `SpacingScale.spaceMd` | 9 dp | Standard internal gap — default between siblings |
| `SpacingScale.spaceMdLg` | 13 dp | Slightly relaxed inset, e.g. a card with more visual weight |
| `SpacingScale.spaceLg` | 15 dp | Standard component internal padding (vertical) |
| `SpacingScale.spaceXl` | 21 dp | Card internal padding, section inset |
| `SpacingScale.space2xl` | 25 dp | Page horizontal margin, wide section padding |
| `SpacingScale.space3xl` | 29 dp | Button horizontal padding, large section leading space |
| `SpacingScale.space4xl` | 35 dp | Hero section spacing, full-width card inset |
| `SpacingScale.space5xl` | 39 dp | Large list item height, section separator |
| `SpacingScale.space6xl` | 47 dp | Bottom sheet top padding, modal inset |
| `SpacingScale.space7xl` | 65 dp | Navigation bar height, fixed bottom area |
| `SpacingScale.space8xl` | 75 dp | Tab bar + content offset |
| `SpacingScale.space9xl` | 95 dp | Scroll offset for sticky headers |
| `SpacingScale.space10xl` | 115 dp | Full-bleed hero image height, large illustration area |

---

## Access pattern

```dart
// CORRECT — import via barrel, reference SpacingScale
import 'package:scapia_tokens/scapia_tokens.dart';

Padding(
  padding: EdgeInsets.symmetric(
    horizontal: SpacingScale.space2xl,   // 25 dp
    vertical: SpacingScale.spaceLg,      // 15 dp
  ),
)

// WRONG — hardcoded number
Padding(padding: EdgeInsets.all(8))

// WRONG — Tier 1 direct
Padding(padding: EdgeInsets.all(SpacingPrimitives.spacing9))
```

---

## Composition recipes

### Inline elements (icon + label on one line)

Use `space2xs` (2 dp) for a tight join or `spaceXs` (5 dp) for a comfortable gap.

```dart
Row(
  children: [
    Icon(icon, size: 16),
    SizedBox(width: SpacingScale.spaceXs),  // 5 dp
    Text(label),
  ],
)
```

### Internal component padding

Most interactive components (buttons, chips, tiles) use `spaceLg` (15 dp) vertical
and `space3xl` (29 dp) horizontal — mirroring the Figma button padding variables.

```dart
Padding(
  padding: EdgeInsets.symmetric(
    vertical: SpacingScale.spaceLg,    // 15 dp
    horizontal: SpacingScale.space3xl, // 29 dp
  ),
)
```

For compact components (tags, badges): use `spaceXs` (5 dp) vertical / `spaceMd`
(9 dp) horizontal.

### Stack / vertical rhythm

Siblings in a `Column` use `spaceMd` (9 dp) between them unless the content is
tightly related (e.g. a label and its helper text), in which case `space2xs`
(2 dp) keeps them visually grouped.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: ...),
    SizedBox(height: SpacingScale.space2xs),  // label → helper: tight
    Text(helperText, style: ...),
    SizedBox(height: SpacingScale.spaceMd),   // group → next group: breathe
    NextSection(),
  ],
)
```

### Card / container inset

Cards use `spaceXl` (21 dp) all-around padding as the default. Upgrade to
`space2xl` (25 dp) when the card has more hierarchy (e.g. a featured card
vs. a compact list row).

```dart
// Standard card inset
Padding(padding: EdgeInsets.all(SpacingScale.spaceXl))   // 21 dp

// Prominent card inset
Padding(padding: EdgeInsets.all(SpacingScale.space2xl))  // 25 dp
```

### Page margins

Horizontal page margins use `space2xl` (25 dp). Apply via a parent `Padding`
or `SliverPadding` — do not repeat it inside every child widget.

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: SpacingScale.space2xl),
  child: Column(...),
)
```

### Between sections on a page

Use `space4xl` (35 dp) between major page sections. Use `spaceMdLg` (13 dp)
between a section header and its first list item.

---

## Rules

- Zero hardcoded `dp` values — every spacing comes from `SpacingScale`
- Never use `SpacingPrimitives` directly in widget code — always go through the Scale
- Do not add `Spacer()` when a fixed `SizedBox` with a token value is predictable
- Asymmetric padding is fine when justified — use two different tokens, not arithmetic

---

## DO / DON'T

```dart
// DO
SizedBox(height: SpacingScale.spaceMd)    // clear intent, themeable
SizedBox(height: SpacingScale.spaceXl)    // standard card inset

// DON'T
SizedBox(height: 9)                            // magic number
SizedBox(height: SpacingPrimitives.spacing9)   // Tier 1 in widget
SizedBox(height: 8 + 1)                        // arithmetic on unknown values
```
