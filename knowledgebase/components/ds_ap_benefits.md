# DsApBenefits

**File:** `packages/ds/lib/src/components/benefits/ds_ap_benefits.dart`
**Figma:** [Seasonal DLS › AP benefits (557:81)](https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=557-81)

---

## API

| Param | Type | Default | Description |
|---|---|---|---|
| `heading` | `String` | required | Title text (Figma `Heading` property) |
| `rewardText` | `String` | required | Chip reward text (Figma `Benefits` property) |
| `state` | `DsApBenefitsState` | required | Visual state |
| `description` | `String` | `'Activate with one tap'` | Subtitle below heading (static in Figma) |
| `onTap` | `VoidCallback?` | `null` | Card tap handler |

## Variant matrix

| Figma `State` | Dart enum | Border | Tag visible |
|---|---|---|---|
| `Active` | `DsApBenefitsState.active` | none | none |
| `Activated` | `DsApBenefitsState.activated` | 2dp `feedbackPositive` | "Active" (green) |
| `Inactive` | `DsApBenefitsState.inactive` | none | "Inactive" (grey) |

## Layout

```
DsApBenefits (SizedBox 166×185)
└── DecoratedBox (bg + optional border) + ClipRRect(r16)
    └── Stack
        ├── Padding(13dp all) → Column(spaceBetween)
        │   ├── SizedBox(66×66) — illustration placeholder
        │   └── Column
        │       ├── heading  Shd-Small, contentPrimary
        │       ├── 2dp gap
        │       ├── description  P-Small, contentSecondary
        │       ├── 9dp gap
        │       └── _RewardChip  (gradient bg, P-extra-small, contentPrimary)
        └── Positioned(top:0, right:0) — _StateTag (activated or inactive only)
```

## Token gaps

| Gap | Figma value | Workaround |
|---|---|---|
| Card background | `#E0EFFF` (VariableID:557:292) | `Color(0xFFE0EFFF)` raw |
| Active badge fill | `#389E0D` (successGreen500) | `colors.feedbackPositive` per `color.md` |
| Chip gradient end | `#B5D5FA` (VariableID:557:494) | `Color(0xFFB5D5FA)` raw in LinearGradient |
| Illustration | 66×66 vector (node 550:5857) | `SizedBox(66,66)` — export pending |
| Active border color | `#389E0D` | `colors.feedbackPositive` per `color.md` |
