# DsButton

> API contract — load this before modifying or extending `DsButton`.

**File:** `packages/ds/lib/src/components/button/ds_button.dart`  
**Figma:** [Seasonal DLS — Button component](https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS)

---

## API

```dart
DsButton({
  required String label,
  VoidCallback? onPressed,                       // null → disabled state
  DsButtonVariant variant = .primary,
  bool isLoading = false,
  IconData? leadingIcon,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `label` | `String` | required | Button label text |
| `onPressed` | `VoidCallback?` | — | Tap handler; `null` renders disabled |
| `variant` | `DsButtonVariant` | `.primary` | Visual style |
| `isLoading` | `bool` | `false` | Shows spinner, blocks interaction |
| `leadingIcon` | `IconData?` | `null` | Icon before the label |

### DsButtonVariant

| Value | Fill | Text | When to use |
|---|---|---|---|
| `primary` | `brandPrimary` (#CE3E00 orange) | `backgroundPrimary` (white) | Single primary CTA — "Book", "Pay", "Continue" |
| `dark` | `brandDark` (#031223 navy) | `backgroundPrimary` (white) | Alternate primary CTA on light backgrounds |
| `secondary` | `backgroundPrimary` (transparent) | `brandPrimary` | Supporting action alongside a primary — "Edit", "Save draft" |
| `ghost` | transparent | `brandPrimary` | Low-emphasis or tertiary action — "Cancel", "Skip" |

---

## Token usage

Tier 3 component tokens (Figma › Button collection) → Tier 2 → Tier 1:

| Property | Tier 3 token | Tier 2 alias | Tier 1 value |
|---|---|---|---|
| Primary fill | `Button/Primary/Orange/Background` | `Brand/Primary` | `primaryScapia800` #CE3E00 |
| Primary text | `Button/Primary/Orange/Label` | `Surface/Background/Primary` | `neutralGrey000` #FFFFFF |
| Dark fill | `Button/Primary/Black/Background` | `Brand/Dark` | `secondaryBlue900` #031223 |
| Dark text | `Button/Primary/Black/Label` | `Surface/Background/Primary` | `neutralGrey000` #FFFFFF |
| Disabled fill | — | `backgroundTertiary` | `neutralGrey200` #E1EAF4 |
| Disabled text | — | `contentTertiary` | `neutralGrey500` #BBC9D9 |
| Secondary/ghost text | — | `brandPrimary` | `primaryScapia800` #CE3E00 |
| Secondary border | — | `brandPrimary` | `primaryScapia800` #CE3E00 |
| Disabled border | — | `borderOpaque` | `neutralGrey200` #E1EAF4 |
| Typography | — | `titleMdSize` / `titleMdWeight` / `titleMdLineheight` | 19 dp / 600 / 27 |
| H padding | — | `Foundation.fontSize29` | 29 dp |
| V padding | — | `Foundation.fontSize19` | 19 dp |
| Icon gap | — | `SpacingScale.spaceMd` | 9 dp |
| Corner radius | — | `RadiusTokens.full` | 999 dp (pill) |

In widget code, access via `ButtonTokens` (Tier 3) or `ColorScale` (Tier 2):

```dart
// Tier 3 — most specific (preferred for button internals)
ButtonTokens.primaryOrangeBackground(context)
ButtonTokens.primaryBlackBackground(context)

// Tier 2 — used for secondary/ghost/disabled states
Theme.of(context).extension<ColorScale>()!.brandPrimary
```

---

## Behaviour spec

- `onPressed: null` → disabled. No tap event fires.
- `isLoading: true` → disabled + label replaced by `CircularProgressIndicator`.
- `leadingIcon` is hidden when `isLoading` is true.
- Hit target height: 65 dp (19 + 27 + 19). Always exceeds 44 dp minimum.
- Disabled state uses both fill (`backgroundTertiary`) and text (`contentTertiary`) dimming — two visual signals, never color alone.

---

## Test coverage

Run from `packages/ds/`:

```bash
flutter test test/components/button/
```

**Golden tests** (12 goldens — 4 variants × 3 states + icon variant):
- `button_{variant}_default.png`
- `button_{variant}_disabled.png`
- `button_{variant}_loading.png`
- `button_primary_with_icon.png`

Regenerate after visual token changes:
```bash
flutter test test/components/button/ --update-goldens
```

**Behaviour tests:**
- Tap fires `onPressed`
- Disabled / loading blocks tap
- Label text visible when not loading
- Spinner visible when loading, label hidden
- Hit target ≥ 44 dp
- `Semantics(button: true)` present

---

## Widgetbook

```bash
cd packages/ds/widgetbook && flutter run -d chrome
```

Use cases: **Interactive** (all knobs), **All variants** (primary / dark / secondary / ghost), **All states — primary**.
