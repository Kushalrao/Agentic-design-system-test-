# StaysPropertyCard

> API contract — load this before modifying or extending `StaysPropertyCard`.

**File:** `packages/ds/lib/src/components/stays/stays_property_card.dart`  
**Figma:** [Alt Stays — Hotel review node 2675:5319](https://www.figma.com/design/dZsOJpJ6G3Fs7WgrYSqt3P/Alt-Stays?node-id=2675-5319)

---

## API

```dart
StaysPropertyCard({
  required String imageUrl,
  required String propertyName,
  required String location,
  required String guestDetails,
  required List<StaysAmenity> amenities,
  int additionalAmenitiesCount = 0,
  double? ratingScore,
  String? ratingLabel,
  String? ratingCount,
  VoidCallback? onViewAllAmenities,
  VoidCallback? onTap,
})

StaysAmenity({
  required String label,
  required Widget icon,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `imageUrl` | `String` | required | URL of the hero property image |
| `propertyName` | `String` | required | Full property name |
| `location` | `String` | required | City / region string |
| `guestDetails` | `String` | required | Guest configuration, e.g. "6 guests • 2 rooms" |
| `amenities` | `List<StaysAmenity>` | required | Amenity chips; empty list hides the row |
| `additionalAmenitiesCount` | `int` | `0` | Overflow count shown on "+N" chip; `0` hides it |
| `ratingScore` | `double?` | `null` | Rating score; `null` hides rating pill |
| `ratingLabel` | `String?` | `null` | Rating verdict, e.g. "Excellent" |
| `ratingCount` | `String?` | `null` | Rating count, e.g. "2.4k ratings" |
| `onViewAllAmenities` | `VoidCallback?` | `null` | Tap handler for "View all amenities"; `null` hides the link |
| `onTap` | `VoidCallback?` | `null` | Card body tap handler |

---

## Layout structure

```
StaysPropertyCard (343 dp wide, ClipRRect r20)
├─ _ImageSection (196 dp tall, Stack)
│  ├─ Image.network                — hero image, cover fit + gradient error fallback
│  └─ Positioned(bottom:13, left:13) — _RatingPill (optional)
│     ├─ _RatingScoreBadge         — orange pill: star icon + score
│     └─ Column                    — label + count (lbSmall)
└─ _ContentSection (Padding: all 13 dp)
   ├─ property name (Hd-Small)
   ├─ SizedBox(7 dp)
   ├─ Row: location_pin + location (P-Small)
   ├─ SizedBox(7 dp)
   ├─ Row: people_icon + guestDetails (P-Small)
   ├─ SizedBox(7 dp)  [if amenities non-empty]
   ├─ _AmenitiesRow (horizontal scroll, chips + optional "+N")
   ├─ SizedBox(7 dp)  [if onViewAllAmenities non-null]
   └─ "View all amenities" GestureDetector (Shd-Small, brandDark)
```

---

## Typography mapping

| Element | Figma style | `TypographyScale` static | Gap? |
|---|---|---|---|
| Property name | Hd-Small (17/600/23) | `hdSmall` | — |
| Location / guest details | P-Small (13/400/21) | `pSmall` | — |
| Amenity chip label | Shd-Small (15/500/23) | `shdSmall` | — |
| "View all amenities" | Shd-Small (15/500/23) | `shdSmall` | — |
| Rating label ("Excellent") | helper-text-01 (10 px/lh12) | `lbSmall` | **Yes — local Alt-Stays style, not in DS** |
| Rating count ("2.4k ratings") | helper-text-01 (10 px/lh12) | `lbSmall` | **Yes — local Alt-Stays style** |
| Rating score | 14 px / SemiBold | `pSmall.copyWith(w600)` | **Yes — 14 px not in Seasonal DLS scale** |

---

## Color mapping

| Element | Figma value | `ColorScale` token | Gap? |
|---|---|---|---|
| Card background | white | `backgroundPrimary` | — |
| Property name | `#262B30` (Text/High emphasis) | `contentPrimary` | **Yes — neutralGrey800, no Tier 2 alias** |
| Location / guests | `#8C9AAA` (Text/Low emphasis) | `contentSecondary` | **Yes — neutralGrey600, no Tier 2 alias** |
| Amenity chip label | `#262B30` | `contentPrimary` | **Yes — same gap** |
| Amenity chip icon | `contentSecondary` via `IconTheme` | `contentSecondary` | — |
| Chip background | `#F1F6FB` | `backgroundSecondary` | — |
| Chip border | `#E1EAF4` | `borderOpaque` | — |
| "View all amenities" | brand link (navy) | `brandDark` | — (confirmed by user) |
| Rating pill overlay | `rgba(0,0,0,0.4)` | `Color(0x66000000)` | **Yes — no Tier 2 overlay token** |
| Rating score badge bg | `#FFF2EC` | `ColorPrimitives.primaryScapia000` | **Yes — Tier 1 only, no Tier 2 alias** |

---

## Spacing mapping

| Element | Value | `SpacingScale` token |
|---|---|---|
| Content padding (all sides) | 13 dp | `spaceMdLg` |
| Icon-to-text gap (location/guest rows) | 5 dp | `spaceXs` |
| Row-to-row gap (all content rows) | 7 dp | `spaceSm` |
| Chip horizontal padding | 9 dp | `spaceMd` |
| Chip vertical padding | 5 dp | `spaceXs` |
| Chip-to-chip gap | 9 dp | `spaceMd` |
| Rating pill position from bottom/left | 13 dp | `spaceMdLg` |

---

## Token gaps (action items)

| Gap | Figma value | Current workaround |
|---|---|---|
| `helper-text-01` | 10 px / Regular / lh 12 (local Alt-Stays style) | `lbSmall` (12 px) |
| Rating score style | 14 px / SemiBold (not in Seasonal DLS) | `pSmall.copyWith(w600)` |
| `#262B30` (Text/High emphasis) | neutralGrey800 | `contentPrimary` |
| `#8C9AAA` (Text/Low emphasis) | neutralGrey600 | `contentSecondary` |
| `primaryScapia000` bg | `#FFF2EC` | `ColorPrimitives.primaryScapia000` (Tier 1) |
| Image overlay | `rgba(0,0,0,0.4)` | `Color(0x66000000)` |
| Chip internal padding sub-tokens | 4 dp / 3 dp / 5 dp in rating badge | hardcoded sub-token values |

---

## Widgetbook

```bash
melos run widgetbook
```

Navigate to **Stays → StaysPropertyCard**.

Use cases:
- **Interactive** — all knobs (property name, location, guest details, rating toggle, amenity count, view-all toggle)
- **Default — full spec** — exact Casa Belvedere card from Figma
- **No rating** — rating pill hidden
- **No amenities** — amenity row hidden
- **Edge — long property name** — tests 2-line truncation
- **Edge — broken image** — gradient fallback renders

---

## Test

```bash
flutter test packages/ds/test/components/stays/
```
