# Spacing

> Load before writing any widget layout code.

---

## The rule in one line

Every gap, padding, and margin comes from `SpacingScale`. No raw numbers, no arithmetic.

---

## The scale

| Token | Value | Use when |
|---|---|---|
| `SpacingScale.spaceNone` | 0 dp | Explicitly remove default padding — intentional zero |
| `SpacingScale.space2xs` | 2 dp | Icon-to-badge nudge, hairline gap, pixel-level alignment |
| `SpacingScale.spaceXs` | 5 dp | Icon-to-label gap, tight chip internal padding |
| `SpacingScale.spaceSm` | 7 dp | Internal padding for small components — tag, badge, chip |
| `SpacingScale.spaceMd` | 9 dp | Standard gap between sibling elements |
| `SpacingScale.spaceMdLg` | 13 dp | Relaxed card inset, section with more visual weight |
| `SpacingScale.spaceLg` | 15 dp | Standard component vertical padding — buttons, inputs |
| `SpacingScale.spaceXl` | 21 dp | Card internal padding, section inset |
| `SpacingScale.space2xl` | 25 dp | Page horizontal margin |
| `SpacingScale.space3xl` | 29 dp | Button horizontal padding, large section leading space |
| `SpacingScale.space4xl` | 35 dp | Between major page sections |
| `SpacingScale.space5xl` | 39 dp | Large list item height, section separator |
| `SpacingScale.space6xl` | 47 dp | Bottom sheet top padding, modal inset |
| `SpacingScale.space7xl` | 65 dp | Navigation bar height, fixed bottom area |
| `SpacingScale.space8xl` | 75 dp | Tab bar + content offset |
| `SpacingScale.space9xl` | 95 dp | Scroll offset for sticky headers |
| `SpacingScale.space10xl` | 115 dp | Full-bleed hero image height, large illustration area |

---

## Choosing between adjacent tokens

**`spaceMd` (9) vs `spaceLg` (15)** — the most common decision:
- `spaceMd`: gap *between* elements that belong to the same group (icon→label, title→subtitle)
- `spaceLg`: padding *inside* a component boundary (button top/bottom, input internal)

**`spaceXl` (21) vs `space2xl` (25)** — card vs. page:
- `spaceXl`: standard card internal padding
- `space2xl`: page-level margin, or a featured card that needs more breathing room

**`spaceSm` (7) vs `spaceXs` (5)** — small component internals:
- `spaceXs`: icon-to-text when the component is very compact (tag, badge)
- `spaceSm`: slightly more generous — chip, pill, small button variant

---

## Composition patterns

### Icon + label on one line
```dart
Row(
  children: [
    Icon(icon, size: 16),
    SizedBox(width: SpacingScale.spaceXs),   // 5 dp — tight join
    Text(label, style: ...),
  ],
)
```
Use `space2xs` (2) for a badge-style nudge. Use `spaceMd` (9) when the icon and label feel like separate elements.

### Component internal padding (button, input, tile)
```dart
Padding(
  padding: EdgeInsets.symmetric(
    vertical:   SpacingScale.spaceLg,    // 15 dp
    horizontal: SpacingScale.space3xl,   // 29 dp
  ),
)
```
Compact components (tag, badge, chip):
```dart
Padding(
  padding: EdgeInsets.symmetric(
    vertical:   SpacingScale.spaceXs,    // 5 dp
    horizontal: SpacingScale.spaceMd,    // 9 dp
  ),
)
```

### Vertical rhythm in a Column
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, ...),
    SizedBox(height: SpacingScale.space2xs),   // 2 dp — label → helper: tightly grouped
    Text(helperText, ...),
    SizedBox(height: SpacingScale.spaceMd),    // 9 dp — group → next group: breathe
    NextSection(),
  ],
)
```
Tight grouping (2 dp) signals "these belong together". Standard gap (9 dp) signals "new group starts here".

### Card internal padding
```dart
Padding(padding: EdgeInsets.all(SpacingScale.spaceXl))    // 21 dp — standard card
Padding(padding: EdgeInsets.all(SpacingScale.space2xl))   // 25 dp — featured/prominent card
```

### Page margins
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: SpacingScale.space2xl),  // 25 dp
  child: Column(...),
)
```
Apply once at the page level via a parent `Padding` or `SliverPadding`. Do not repeat it inside each child.

### Between major sections
```dart
SizedBox(height: SpacingScale.space4xl)     // 35 dp — between page sections
SizedBox(height: SpacingScale.spaceMdLg)    // 13 dp — section header → first list item
```

### List items
For list items with title + subtitle, the vertical rhythm inside is:
```dart
Column(
  children: [
    Text(title, style: TypographyScale.shdSmall.copyWith(...)),
    SizedBox(height: SpacingScale.space2xs),    // 2 dp — title → subtitle
    Text(subtitle, style: TypographyScale.pSmall.copyWith(...)),
  ],
)
```

---

## Flutter layout decisions

**`SizedBox` vs `Spacer()`**
Use `SizedBox` with a token value when the gap is known and predictable. `Spacer()` is for flexible remaining space — do not use it when a specific gap is intended.

**`Expanded` vs fixed `SizedBox`**
- `Expanded`: child should fill available space — e.g. a text field in a row with a button
- Fixed `SizedBox`: gap is a design decision, not dependent on available space

**Asymmetric padding**
Fine when justified. Use two separate tokens (`pl: spaceMdLg, pr: spaceLg`) — never arithmetic on one token (`spaceLg + 2`).

---

## Rules

- Zero hardcoded `dp` values — every spacing value comes from `SpacingScale`
- Never use `SpacingPrimitives` directly in widget code
- No arithmetic on tokens (`spaceMd + 4`) — if the value doesn't exist, ask
- No `Spacer()` when a fixed `SizedBox` with a token is predictable

---

## DO / DON'T

```dart
// DO
SizedBox(height: SpacingScale.spaceMd)     // clear intent, token-tracked
Padding(padding: EdgeInsets.all(SpacingScale.spaceXl))

// DON'T
SizedBox(height: 9)                                 // magic number
SizedBox(height: SpacingPrimitives.spacing9)        // Tier 1 in widget
SizedBox(height: SpacingScale.spaceMd + 4)          // arithmetic on tokens
Padding(padding: EdgeInsets.all(8))                 // hardcoded
```
