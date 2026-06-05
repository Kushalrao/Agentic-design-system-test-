# DsStayStars

> API contract — load this before modifying or extending `DsStayStars`.

**File:** `packages/ds/lib/src/components/rating/ds_stay_stars.dart`
**Figma:** [Seasonal DLS › Stay stars (node 489:1059)](https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=489-1059)

---

## API

```dart
DsStayStars({
  required int starCount,
  String? label,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `starCount` | `int` | required | Number of stars (1–5). Figma currently designs 5 only. |
| `label` | `String?` | `null` | Label after stars (e.g. `"5 star hotel"`). `null` = stars only |

---

## Variant matrix

| Figma property | Options | Dart condition |
|---|---|---|
| `Label#489:3` (BOOLEAN) | true / false | `label != null` |
| `Label#489:4` (TEXT) | any string | `label` parameter value |
| `Property 1` (VARIANT) | Default only | — (single variant) |

---

## Layout structure

```
DsStayStars (Row, HUG×HUG, CrossAxisAlignment.center)
├── Stars Row (Row, HUG×HUG, gap: space2xs=2dp)
│   ├── SvgPicture 11×11 (staystarsStaystars11px, colorFilter: brandDark)
│   ├── SizedBox(2dp)
│   ├── SvgPicture 11×11
│   ├── ... × starCount
└── if label != null:
    ├── SizedBox(7dp = spaceSm)
    └── Text(label) — lbSmall, contentSecondary
```

---

## Token usage

| Property | Figma variable | Dart token | Match |
|---|---|---|---|
| Stars → label gap | `Spacing/7` (VariableID:225:3956) | `SpacingScale.spaceSm` | EXACT |
| Star → star gap | `Spacing/2` (VariableID:225:3954) | `SpacingScale.space2xs` | EXACT |
| Star icon | `Staystars/ 11px` (node 497:1241) | `ScapiaIcons.staystarsStaystars11px` | EXACT |
| Star color | `Brand/Dark` (VariableID:334:10807) | `colors.brandDark` | EXACT |
| Label style | `Lb-Small` (style 228:4700) | `TypographyScale.lbSmall` | EXACT |
| Label color | `Surface/Content/Secondary` (VariableID:334:10803) | `colors.contentSecondary` | EXACT |

## No token gaps — all values resolved exactly.

---

## Widgetbook

Navigate to **Rating → DsStayStars**.

Use cases: Interactive (star slider + label toggle), 5 stars with label, stars only, 3 stars, 1 star.
