# Color

> Semantic intent rules — which token to use and when.
> Load this file before applying any color in a widget.

---

## Access pattern

**Always and only** access color via the `ThemeExtension`. Never import
`ColorPrimitives` directly inside a widget.

```dart
// CORRECT — resolves to the active theme (light / dark / seasonal)
final colors = Theme.of(context).extension<ColorScale>()!;
Container(color: colors.backgroundPrimary);

// WRONG — hardcoded hex
Container(color: Color(0xFFFFFFFF));

// WRONG — Flutter built-in
Container(color: Colors.white);

// WRONG — reaching into Tier 1 from a widget
Container(color: ColorPrimitives.neutralGrey000);
```

---

## Token groups

### Brand — primary interactive colors

| Token | Tier 1 reference | Hex | Intent |
|---|---|---|---|
| `brandPrimary` | `Primary/Scapia/800` | #CE3E00 | Brand orange — primary CTA, active state, brand moment |
| `brandDark` | `Secondary/Blue/900` | #031223 | Dark navy — alternate primary CTA, high-contrast surface |

### Feedback — status states

| Token | Tier 1 reference | Hex | Intent |
|---|---|---|---|
| `feedbackNegative` | `Warning/Red/400` | #F5222D | Error, destructive, failed transaction |
| `feedbackWarning` | `Alert/Yellow/400` | #FAAD14 | Caution, pending, review required |
| `feedbackPositive` | `Success/Green/400` | #52C41A | Success, confirmed, approved |

### Surface › Background — page and container fills

| Token | Tier 1 reference | Hex | Intent |
|---|---|---|---|
| `backgroundPrimary` | `Neutral/Grey/000` | #FFFFFF | Default page background. Start here. |
| `backgroundSecondary` | `Neutral/Grey/100` | #F1F6FB | Card, section, alternate row. One level back. |
| `backgroundTertiary` | `Neutral/Grey/200` | #E1EAF4 | Subtle wash, disabled fill, recessed area. |

### Surface › Content — text and icons

| Token | Tier 1 reference | Hex | Intent |
|---|---|---|---|
| `contentPrimary` | `Neutral/Grey/900` | #121212 | Body copy, headings, labels — default for all text. |
| `contentSecondary` | `Neutral/Grey/700` | #4B545E | Supporting text — captions, subtitles, helper lines. |
| `contentTertiary` | `Neutral/Grey/500` | #BBC9D9 | Disabled text, placeholder, de-emphasised metadata. |

### Surface › Border — strokes and dividers

| Token | Tier 1 reference | Hex | Intent |
|---|---|---|---|
| `borderOpaque` | `Neutral/Grey/200` | #E1EAF4 | Default card outline, input idle border, divider. |
| `borderSelection` | `Neutral/Grey/900` | #121212 | Selected / focused state border — high contrast. |

---

## Pairing rules

| Rule | Reason |
|---|---|
| `brandPrimary` fill → use `backgroundPrimary` (white) for text | `contentPrimary` (near-black) on orange has lower contrast than white. |
| `brandDark` fill → use `backgroundPrimary` (white) for text | Dark navy requires white text to pass WCAG AA. |
| Feedback tokens are standalone colors | Use directly as icon/text/border color. Pair with `backgroundSecondary` or `backgroundTertiary` for a tinted surface. |
| Disabled state | `contentTertiary` text on `backgroundTertiary` fill is the **only** valid disabled pairing. |
| Never convey state by color alone | Always pair a color change with an icon or text label. |

---

## DO / DON'T

```dart
// DO — semantic surface for a card
DecoratedBox(
  decoration: BoxDecoration(
    color: colors.backgroundPrimary,
    border: Border.all(color: colors.borderOpaque),
    borderRadius: BorderRadius.circular(RadiusTokens.r12),
  ),
)

// DON'T — hardcoded neutral
DecoratedBox(
  decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
)
```

```dart
// DO — brand button with correct text pairing
DsButton(
  label: 'Book flights',
  onPressed: () {},
  variant: DsButtonVariant.primary,  // orange fill, white label
)

// DON'T — contentPrimary on brandPrimary (contrast risk)
Container(
  color: colors.brandPrimary,
  child: Text('Go', style: TextStyle(color: colors.contentPrimary)),
)
```

```dart
// DO — feedback color as inline status
Row(
  children: [
    Icon(Icons.error, color: colors.feedbackNegative),
    SizedBox(width: SpacingScale.space2xs),
    Text('Payment failed', style: TextStyle(color: colors.feedbackNegative)),
  ],
)

// DON'T — using a primitive directly
Icon(Icons.error, color: ColorPrimitives.warningRed400)
```

---

## Theme-switching contract

`ColorScale` is a `ThemeExtension<ColorScale>`. The active instance is registered
in `ScapiaTheme.light()` (and future `dark()` / seasonal variants) via
`ThemeData.extensions`. When a new theme mode ships, only `ColorScale` needs
updating — no widget code changes.

```dart
// ScapiaTheme wires the extension — widgets don't need to know which mode is active
extensions: [ColorScale.light],
```

---

## What NOT to do (quick ref)

- `Colors.*` from Flutter — banned
- `Color(0xFF...)` literals in widget files — banned
- `ColorPrimitives.*` in widgets — banned (Tier 1 only for token tests)
- Accessing `ThemeData.colorScheme` for semantic colors — use `ColorScale` instead
