# StaysSrpCard

> API contract — load this before modifying or extending `StaysSrpCard`.

**File:** `packages/ds/lib/src/components/stays/stays_srp_card.dart`  
**Figma:** [Alt Stays — SRP node 2608:5110](https://www.figma.com/design/dZsOJpJ6G3Fs7WgrYSqt3P/Alt-Stays?node-id=2608-5110)

---

## API

```dart
StaysSrpCard({
  required String imageUrl,
  required String hotelName,
  required int starCount,
  required String location,
  required String pricePerNight,
  required int discountPercent,
  required String taxesLabel,
  required String rewardsAmount,
  double? ratingScore,
  String? ratingLabel,
  String? ratingCount,
  List<String> offers = const [],
  int currentImageIndex = 0,
  int totalImages = 1,
  VoidCallback? onShortlistTap,
  VoidCallback? onTap,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `imageUrl` | `String` | required | URL of the hero hotel image |
| `hotelName` | `String` | required | Full hotel name |
| `starCount` | `int` | required | Star classification 1–5 |
| `location` | `String` | required | City / region string |
| `pricePerNight` | `String` | required | Formatted price, e.g. "₹ 10,360" |
| `discountPercent` | `int` | required | Discount shown on badge; `0` hides it |
| `taxesLabel` | `String` | required | Taxes line, e.g. "+ 1,243 taxes & fees" |
| `rewardsAmount` | `String` | required | Rewards amount, e.g. "₹4,600" |
| `ratingScore` | `double?` | `null` | Rating score; `null` hides the pill |
| `ratingLabel` | `String?` | `null` | Rating verdict, e.g. "Excellent" |
| `ratingCount` | `String?` | `null` | Rating count, e.g. "2.4k ratings" |
| `offers` | `List<String>` | `[]` | Offer labels; empty list hides the row |
| `currentImageIndex` | `int` | `0` | Active pagination dot index |
| `totalImages` | `int` | `1` | Total images; `1` hides pagination |
| `onShortlistTap` | `VoidCallback?` | `null` | Shortlist tap handler; `null` hides button |
| `onTap` | `VoidCallback?` | `null` | Card body tap handler |

---

## Layout structure

```
StaysSrpCard (343dp wide, ClipRRect r20)
├─ _ImageSection (400dp tall, Stack)
│  ├─ Image.network                 — hero image, cover fit
│  ├─ Positioned(top, right)        — _ShortlistButton
│  ├─ Positioned(bottom-left)       — _RatingPill
│  │  ├─ _RatingScoreBadge          — orange pill: star icon + score
│  │  └─ Column                     — label + count text
│  └─ Positioned(bottom, center)    — _PaginationDots
└─ _InfoSection
   ├─ Padding(l:13, r:15, t:15) Row(justify-between)
   │  ├─ Expanded: _HotelDetails
   │  │  ├─ hotel name (P-Medium)
   │  │  ├─ ★ stars + "N star hotel" (P-Small)
   │  │  ├─ location row (P-Small)
   │  │  └─ offers Wrap (_OfferItem)
   │  └─ _PriceColumn (end-aligned)
   │     ├─ _DiscountBadge
   │     ├─ price + /night row (Hd-Small + lbSmall)
   │     └─ taxes text (P-Small)
   └─ _RewardsBar (centered Row)
```

---

## Typography mapping

| Element | Figma style | `TypographyScale` static | Gap? |
|---|---|---|---|
| Hotel name | P-Medium (15/400/23) | `pMedium` | — |
| Star label / location / taxes | P-Small (13/400/21) | `pSmall` | — |
| Shortlist label | P-Small (13/400/21) | `pSmall` | — |
| Rewards text | P-Small (13/400/21) | `pSmall` | — |
| Price amount | Hd-Small (17/600/23) | `hdSmall` | — |
| Rating score | 14px/SemiBold (no DS style) | `pSmall.copyWith(w600)` | **Yes — 14px not in Seasonal DLS scale** |
| Rating labels / offers / discount / /night | helper-text-01 (10px) / captions-01 (12px/lh16) | `lbSmall` | **Yes — local Alt-Stays styles, not in DS** |

---

## Color mapping

| Element | Figma variable / value | `ColorScale` token | Gap? |
|---|---|---|---|
| Card background | `--surface/background/primary` | `backgroundPrimary` | — |
| Hotel name color | `--surface/content/primary` | `contentPrimary` | — |
| Star / location / taxes color | `--surface/content/secondary` | `contentSecondary` | — |
| Shortlist text | `--surface/content/primary` | `contentPrimary` | — |
| Discount badge fill | `--primary/orange/background` | `brandPrimary` | — |
| Discount text | white | `backgroundPrimary` | — |
| Star icons | `feedbackWarning` | `feedbackWarning` | — |
| Offer text | #389E0D (Success/Green/500) | `feedbackPositive` | **Yes — successGreen500, Tier 2 = 400** |
| Rewards text | #D48806 (Alert/Yellow/500) | `feedbackWarning` | **Yes — alertYellow500, Tier 2 = 400** |
| Price color | #262B30 (Text/High emphasis) | `contentPrimary` | **Yes — neutralGrey800, no Tier 2 alias** |
| /night + taxes color | #8C9AAA (Text/Low emphasis) | `contentSecondary` | **Yes — neutralGrey600, no Tier 2 alias** |
| Rating score badge bg | #FFF2EC (`primaryScapia000`) | `ColorPrimitives.primaryScapia000` | **Yes — Tier 1 only, no Tier 2 alias** |
| Rating pill overlay bg | `rgba(0,0,0,0.4)` | `Color(0x66000000)` | **Yes — no Tier 2 overlay token** |

---

## Spacing mapping

| Element | Figma variable | `SpacingScale` token |
|---|---|---|
| Shortlist horizontal padding | `--spacing/13` | `spaceMdLg` |
| Shortlist vertical padding | `--spacing/9` | `spaceMd` |
| Info left padding | `--spacing/13` | `spaceMdLg` |
| Info right/top padding | `--spacing/15` | `spaceLg` |
| Hotel details gap | `--spacing/9` | `spaceMd` |
| Hotel name → stars gap | `--spacing/7` | `spaceSm` |
| Location gap | `--spacing/5` | `spaceXs` |
| Discount horizontal padding | `--spacing/7` | `spaceSm` |
| Discount vertical padding | `--spacing/5` | `spaceXs` |
| Rewards vertical padding | `--spacing/7` | `spaceSm` |

---

## Token gaps (action items)

These values appear in the Figma design but have no Tier 2 alias in Seasonal DLS yet. Raise with design team before next DS release.

| Gap | Figma value | Current workaround |
|---|---|---|
| `helper-text-01` text style | 10px / Regular / lh 12 (local Alt-Stays style) | `lbSmall` (12px) |
| `captions-01` text style | 12px / Regular / lh 16 (local Alt-Stays style) | `lbSmall` (12px / lh 19) |
| Rating score | 14px / SemiBold (no DS style) | `pSmall.copyWith(w600)` |
| Text/High emphasis | #262B30 (neutralGrey800) | `contentPrimary` (#121212) |
| Text/Low emphasis | #8C9AAA (neutralGrey600) | `contentSecondary` (#4B545E) |
| Success/Green/500 | #389E0D | `feedbackPositive` (#52C41A) |
| Alert/Yellow/500 | #D48806 | `feedbackWarning` (#FAAD14) |
| `primaryScapia000` bg | #FFF2EC | `ColorPrimitives.primaryScapia000` (Tier 1) |
| Image overlay | rgba(0,0,0,0.4) | `Color(0x66000000)` |

---

## Widgetbook

```bash
cd packages/ds/widgetbook && flutter run -d chrome
```

Navigate to **Stays SRP → StaysSrpCard**.

Use cases:
- **Interactive** — all knobs (name, price, discount, stars, rewards, rating toggle, shortlist toggle, image index)
- **Default — full spec** — exact Grand Mercure card from Figma
- **Minimal — no offers, no discount** — `totalImages: 1` hides pagination
- **Edge — long hotel name** — tests 2-line truncation
- **Edge — broken image** — gradient fallback renders

---

## Test

```bash
flutter test packages/ds/test/components/stays/
```
