# DsScapiaScore

> API contract — load this before modifying or extending `DsScapiaScore`.

**File:** `packages/ds/lib/src/components/rating/ds_scapia_score.dart`
**Figma:** [Seasonal DLS › Scapia score (node 482:244)](https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=482-244)

---

## API

```dart
DsScapiaScore({
  required double score,
  String? label,
  String? count,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `score` | `double` | required | Numeric rating, e.g. `4.2` |
| `label` | `String?` | `null` | Rating verdict, e.g. `"Excellent"`. `null` → compact (score-only) state |
| `count` | `String?` | `null` | Rating count, e.g. `"2.4k ratings"`. Only shown when `label` is non-null |

---

## Variant matrix

| Figma property | Options | Dart condition | Notes |
|---|---|---|---|
| `State` | `With label` / `without label` | `label != null` | Drives layout + radius |

---

## Layout structure

```
DsScapiaScore
└── ClipRRect (r12 with label / r8 without)
    └── BackdropFilter (blur σ44)
        └── DecoratedBox (rgba(0,0,0,0.4) fill)
            └── Padding (L:5 R:9 T/B:2 with label / zero without)
                └── Row
                    ├── _ScoreBadge
                    │   └── DecoratedBox (primaryScapia000, r8)
                    │       └── Padding (H:5 V:2)
                    │           └── Row
                    │               ├── [icon 11×11 — gap, see below]
                    │               ├── SizedBox(w: 2 dp)
                    │               └── Text(score) — pExtraSmall, brandPrimary
                    └── if label != null:
                        ├── SizedBox(w: 5 dp)
                        └── _LabelColumn
                            ├── Text(label) — pExtraSmall, backgroundPrimary
                            └── if count != null:
                                Text(count) — pExtraSmall, contentTertiary
```

---

## Differential token table

| Property | With label | Without label |
|---|---|---|
| Outer cornerRadius | `RadiusTokens.r12` | `RadiusTokens.r8` |
| Outer paddingLeft | `SpacingScale.spaceXs` (5 dp) | `0` |
| Outer paddingRight | `SpacingScale.spaceMd` (9 dp) | `0` |
| Outer paddingTop/Bottom | `SpacingScale.space2xs` (2 dp) | `0` |
| Outer itemSpacing | `SpacingScale.spaceXs` (5 dp) | `0` |
| Label column | visible | absent |

---

## Typography mapping

| Element | Figma style | `TypographyScale` static |
|---|---|---|
| Score text | P-extra-small (10/400/15) | `pExtraSmall` |
| Rating verdict | P-extra-small (10/400/15) | `pExtraSmall` |
| Rating count | P-extra-small (10/400/15) | `pExtraSmall` |

> Note: `P-extra-small` (10 px / Regular / lh 15) was added to `TypographyScale` as part of this component implementation.

---

## Token usage

| Property | Figma variable | Dart token |
|---|---|---|
| Score text color | `Brand/Primary` | `colors.brandPrimary` |
| Rating verdict color | `Surface/Content/Primary` (dark context = white) | `colors.backgroundPrimary` |
| Rating count color | `Surface/Content/Tertiary` | `colors.contentTertiary` |
| Score badge bg | `#FFEAE0` (primaryScapia000) | `ColorPrimitives.primaryScapia000` — gap |
| Outer overlay | `rgba(0,0,0,0.4)` | `Color(0x66000000)` — gap |
| Outer blur | BACKGROUND_BLUR radius 44 | raw `44.0` — no token |

---

## Token gaps

| Gap | Figma value | Workaround | Resolution |
|---|---|---|---|
| Score badge background | `#FFEAE0` (primaryScapia000) | `ColorPrimitives.primaryScapia000` (Tier 1) | Add Tier 2 alias when pattern recurs in 3+ components |
| Overlay fill | `rgba(0,0,0,0.4)` | `Color(0x66000000)` | Add overlay token when dark overlays are a DS pattern |
| Backdrop blur sigma | `44` | raw `44.0` | Add blur token if this value recurs |
| `Scapia score/ 11px` icon | Figma node 492:901 | `SizedBox(11,11)` placeholder | Export via Desktop Bridge → add to `ScapiaIcons.scapiaScoreScapiaScore11px` |

---

## Icon — pending resolution

The lightning bolt icon inside the score badge (`Scapia score/ 11px`, node `492:901`) was not included in the bulk icon export because its Figma name has only 2 segments (`Scapia score/ 11px`) and the export script requires 3.

**To fix:**
1. Reconnect Desktop Bridge plugin in Figma Desktop
2. Agent will export node 492:901 → `packages/ds/assets/icons/scapia-score/scapia-score_11px.svg`
3. Agent will add `ScapiaIcons.scapiaScoreScapiaScore11px` constant
4. Agent will replace `SizedBox(11,11)` placeholder in `_ScoreBadge` with the SVG

---

## Widgetbook

```bash
melos run widgetbook
```

Navigate to **Rating → DsScapiaScore**.

Use cases:
- **Interactive** — score slider, label toggle, label/count text knobs
- **With label — full spec** — exact Figma "With label" variant
- **Without label — compact** — exact Figma "without label" variant
- **Edge — label without count** — label shown, no count line
- **Edge — score 1.0** / **Edge — score 5.0** — extreme rating values

---

## Existing usages to migrate

These components use private implementations of the rating pill pattern. Once `DsScapiaScore` is stable, migrate them:

| Component | Location | Status |
|---|---|---|
| `StaysSrpCard` | `_RatingPill` + `_RatingScoreBadge` | Pending migration |
| `StaysPropertyCard` | `_RatingPill` + `_RatingScoreBadge` | Pending migration |
