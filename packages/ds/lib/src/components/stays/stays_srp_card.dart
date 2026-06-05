import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

/// Hotel SRP (Search Results Page) card — 343dp wide.
///
/// Displays a hotel listing with an image section (hero image, rating pill,
/// shortlist button, pagination dots) and a hotel info section (name, stars,
/// location, offers, price, rewards bar).
///
/// ## Typography — Figma style → TypographyScale static
/// | Element | Figma style | Static |
/// |---|---|---|
/// | Hotel name | P-Medium | `TypographyScale.pMedium` |
/// | Stars / location / taxes | P-Small | `TypographyScale.pSmall` |
/// | Shortlist label | P-Small | `TypographyScale.pSmall` |
/// | Price amount | Hd-Small | `TypographyScale.hdSmall` |
/// | Rating labels / offers / discount / /night | helper-text-01 / captions-01 | `TypographyScale.lbSmall` *(gap — 10–12px, see below)* |
///
/// ## Known token gaps
/// - `helper-text-01` (10px/Regular/12lh) and `captions-01` (12px/Regular/16lh) are
///   local styles in the Alt-Stays file, not yet in Seasonal DLS. Closest: `lbSmall` (12px).
/// - `#262B30` (Text/High emphasis, neutralGrey800) → `contentPrimary` (#121212).
/// - `#8C9AAA` (Text/Low emphasis, neutralGrey600) → `contentSecondary` (#4B545E).
/// - `#389E0D` (Success/Green/500) → `feedbackPositive` (successGreen400, #52C41A).
/// - `#D48806` (Alert/Yellow/500) → `feedbackWarning` (alertYellow400, #FAAD14).
/// - `#FFF2EC` (primaryScapia000) — Tier 1 only, no Tier 2 alias yet.
/// - Overlay bg `rgba(0,0,0,0.4)` — no Tier 2 overlay token.
class StaysSrpCard extends StatelessWidget {
  const StaysSrpCard({
    super.key,
    required this.imageUrl,
    required this.hotelName,
    required this.starCount,
    required this.location,
    required this.pricePerNight,
    required this.discountPercent,
    required this.taxesLabel,
    required this.rewardsAmount,
    this.ratingScore,
    this.ratingLabel,
    this.ratingCount,
    this.offers = const [],
    this.currentImageIndex = 0,
    this.totalImages = 1,
    this.onShortlistTap,
    this.onTap,
  });

  /// URL of the hero hotel image.
  final String imageUrl;

  /// Full hotel name, e.g. "Grand Mercure Phuket Patong".
  final String hotelName;

  /// Star classification (1–5).
  final int starCount;

  /// Location string, e.g. "Shimla, India".
  final String location;

  /// Formatted price, e.g. "₹ 10,360".
  final String pricePerNight;

  /// Discount percentage shown on the orange badge. `0` hides the badge.
  final int discountPercent;

  /// Taxes/fees label, e.g. "+ 1,243 taxes & fees".
  final String taxesLabel;

  /// Rewards amount string, e.g. "₹4,600".
  final String rewardsAmount;

  /// Rating score, e.g. 4.2. `null` hides the rating pill entirely.
  final double? ratingScore;

  /// Short rating verdict, e.g. "Excellent".
  final String? ratingLabel;

  /// Rating count label, e.g. "2.4k ratings".
  final String? ratingCount;

  /// Short offer strings, e.g. `["Book with ₹0", "Free cancellation"]`.
  final List<String> offers;

  /// Zero-based index of the currently visible image (drives pagination dots).
  final int currentImageIndex;

  /// Total number of images in the carousel. `1` hides pagination dots.
  final int totalImages;

  /// Called when the Shortlist button is tapped. `null` hides the button.
  final VoidCallback? onShortlistTap;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  static const double _cardWidth   = 343;
  static const double _imageHeight = 400;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorScale>()!;
    return SizedBox(
      width: _cardWidth,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RadiusTokens.r20),
          child: ColoredBox(
            color: colors.backgroundPrimary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImageSection(
                  imageUrl:          imageUrl,
                  ratingScore:       ratingScore,
                  ratingLabel:       ratingLabel,
                  ratingCount:       ratingCount,
                  currentImageIndex: currentImageIndex,
                  totalImages:       totalImages,
                  onShortlistTap:    onShortlistTap,
                  colors:            colors,
                ),
                _InfoSection(
                  hotelName:       hotelName,
                  starCount:       starCount,
                  location:        location,
                  pricePerNight:   pricePerNight,
                  discountPercent: discountPercent,
                  taxesLabel:      taxesLabel,
                  rewardsAmount:   rewardsAmount,
                  offers:          offers,
                  colors:          colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Image Section ────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.imageUrl,
    required this.ratingScore,
    required this.ratingLabel,
    required this.ratingCount,
    required this.currentImageIndex,
    required this.totalImages,
    required this.onShortlistTap,
    required this.colors,
  });

  final String imageUrl;
  final double? ratingScore;
  final String? ratingLabel;
  final String? ratingCount;
  final int currentImageIndex;
  final int totalImages;
  final VoidCallback? onShortlistTap;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: StaysSrpCard._imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [colors.backgroundTertiary, colors.backgroundSecondary],
                ),
              ),
            ),
          ),

          // Shortlist button — top-right (Figma: top:16, right:~14)
          if (onShortlistTap != null)
            Positioned(
              top:   SpacingScale.spaceLg,    // 15dp ≈ Figma 16dp
              right: SpacingScale.spaceMdLg,  // 13dp ≈ Figma 14dp
              child: _ShortlistButton(onTap: onShortlistTap!, colors: colors),
            ),

          // Rating pill — bottom-left (Figma: left:12, top:355 → bottom:~45)
          if (ratingScore != null)
            Positioned(
              left:   SpacingScale.spaceMdLg, // 13dp ≈ Figma 12dp
              bottom: SpacingScale.space6xl,  // 47dp ≈ image_height - 355 = 45dp
              child: _RatingPill(
                score:  ratingScore!,
                label:  ratingLabel,
                count:  ratingCount,
                colors: colors,
              ),
            ),

          // Pagination dots — bottom-center (Figma: top:380 → bottom:20)
          if (totalImages > 1)
            Positioned(
              bottom: SpacingScale.spaceLg, // 15dp ≈ Figma 20dp
              left:   0,
              right:  0,
              child: Center(
                child: _PaginationDots(
                  current: currentImageIndex,
                  total:   totalImages,
                  colors:  colors,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Shortlist Button ─────────────────────────────────────────────────────────

class _ShortlistButton extends StatelessWidget {
  const _ShortlistButton({required this.onTap, required this.colors});

  final VoidCallback onTap;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.r32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Figma: backdrop-blur-[2px]
        child: GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:        colors.backgroundPrimary,
              // Gap: Border/1 variable = 1 dp; no BorderTokens class yet
              border:       Border.all(width: 1.0, color: colors.backgroundPrimary), // ds-lint-ignore: no_bare_border
              borderRadius: BorderRadius.circular(RadiusTokens.r32),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingScale.spaceMdLg, // 13dp ✓ var(--spacing/13)
                vertical:   SpacingScale.spaceMd,   // 9dp  ✓ var(--spacing/9)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "+ " icon — Figma uses a 16×16 plus SVG
                  Icon(Icons.add, size: 16, color: colors.contentPrimary),
                  const SizedBox(width: SpacingScale.space2xs),
                  // P-Small: 13 / Regular / lh 21 ✓  var(--font/size/13, --font/lineheight/21)
                  Text(
                    'Shortlist',
                    style: TypographyScale.pSmall.copyWith(color: colors.contentPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Rating Pill ──────────────────────────────────────────────────────────────

class _RatingPill extends StatelessWidget {
  const _RatingPill({
    required this.score,
    required this.label,
    required this.count,
    required this.colors,
  });

  final double score;
  final String? label;
  final String? count;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.r16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Gap: rgba(0,0,0,0.4) — no Tier 2 overlay token
            color:        const Color(0x66000000), // ds-lint-ignore: no_hardcoded_color — overlay bg, no Tier 2 token yet
            borderRadius: BorderRadius.circular(RadiusTokens.r16),
          ),
          child: Padding(
            // Gap: pl:4, pr:6, py:4 — no matching SpacingScale tokens (sub-token values)
            padding: const EdgeInsets.only(left: 4, right: 6, top: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Orange star+score badge
                _RatingScoreBadge(score: score, colors: colors),
                // Gap: 4dp — between space2xs(2) and spaceXs(5); using fixed value
                const SizedBox(width: 4),
                // Stacked label + count
                if (label != null || count != null)
                  Column(
                    mainAxisSize:        MainAxisSize.min,
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      if (label != null)
                        // Gap: helper-text-01 (10px) → lbSmall (12px) closest
                        Text(
                          label!,
                          style: TypographyScale.lbSmall.copyWith(
                            color: colors.backgroundPrimary,
                          ),
                        ),
                      if (count != null)
                        Text(
                          count!,
                          style: TypographyScale.lbSmall.copyWith(
                            // 85% opacity white per Figma: rgba(255,255,255,0.85)
                            color: colors.backgroundPrimary.withAlpha(217),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingScoreBadge extends StatelessWidget {
  const _RatingScoreBadge({required this.score, required this.colors});

  final double score;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Gap: #FFF2EC = primaryScapia000 — Tier 1 only, no Tier 2 alias yet
        color:        ColorPrimitives.primaryScapia000, // ds-lint-ignore: no_tier1_in_widgets — star badge tint, no Tier 2 alias yet
        borderRadius: BorderRadius.circular(RadiusTokens.r24),
      ),
      child: Padding(
        // Gap: px:5, pt:3, pb:4 — sub-token values from Figma spec
        padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Star icon — Figma: 10×12 custom SVG
            Icon(Icons.star_rounded, size: 10, color: colors.brandPrimary),
            // Gap: 3dp — sub-token value
            const SizedBox(width: 3),
            // Gap: Figma 14px/SemiBold; 14px not in scale → pSmall(13) + w600
            // Gap: color #262B30 (Text/High emphasis, neutralGrey800) → contentPrimary
            Text(
              score.toStringAsFixed(1),
              style: TypographyScale.pSmall.copyWith(
                fontWeight: FontWeight.w600,
                color:      colors.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pagination Dots ──────────────────────────────────────────────────────────

class _PaginationDots extends StatelessWidget {
  const _PaginationDots({
    required this.current,
    required this.total,
    required this.colors,
  });

  final int current;
  final int total;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return Padding(
          // Gap: Figma gap-[6dp] between dots; spaceXs(5) is closest
          padding: EdgeInsets.only(left: i > 0 ? SpacingScale.spaceXs : 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:        isActive
                  ? colors.backgroundPrimary
                  : colors.backgroundPrimary.withAlpha(128), // 50% opacity
              borderRadius: BorderRadius.circular(RadiusTokens.r8),
            ),
            child: SizedBox(
              width:  isActive ? 8.0 : 6.0, // Figma: active=8, inactive=6
              height: isActive ? 8.0 : 6.0,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Info Section ─────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.hotelName,
    required this.starCount,
    required this.location,
    required this.pricePerNight,
    required this.discountPercent,
    required this.taxesLabel,
    required this.rewardsAmount,
    required this.offers,
    required this.colors,
  });

  final String hotelName;
  final int starCount;
  final String location;
  final String pricePerNight;
  final int discountPercent;
  final String taxesLabel;
  final String rewardsAmount;
  final List<String> offers;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hotel details row — pl:13, pr:15, pt:15  (Figma: var(--spacing/13,13), /15, /15)
        Padding(
          padding: const EdgeInsets.only(
            left:  SpacingScale.spaceMdLg, // 13dp ✓
            right: SpacingScale.spaceLg,   // 15dp ✓
            top:   SpacingScale.spaceLg,   // 15dp ✓
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — hotel name, stars, location, offers
              Expanded(
                child: _HotelDetails(
                  hotelName: hotelName,
                  starCount: starCount,
                  location:  location,
                  offers:    offers,
                  colors:    colors,
                ),
              ),
              // Right — discount badge + price
              _PriceColumn(
                pricePerNight:   pricePerNight,
                discountPercent: discountPercent,
                taxesLabel:      taxesLabel,
                colors:          colors,
              ),
            ],
          ),
        ),
        // gap: var(--spacing/9) = spaceMd (9dp) between hotel details and rewards bar
        const SizedBox(height: SpacingScale.spaceMd),
        // Rewards bar
        _RewardsBar(rewardsAmount: rewardsAmount, colors: colors),
      ],
    );
  }
}

// ─── Hotel Details (left column) ──────────────────────────────────────────────

class _HotelDetails extends StatelessWidget {
  const _HotelDetails({
    required this.hotelName,
    required this.starCount,
    required this.location,
    required this.offers,
    required this.colors,
  });

  final String hotelName;
  final int starCount;
  final String location;
  final List<String> offers;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:       MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel name container — gap: var(--spacing/7) = spaceSm (7dp)
        Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // P-Medium: 15 / Regular / lh 23 ✓  var(--font/size/15, --font/lineheight/23)
            Text(
              hotelName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TypographyScale.pMedium.copyWith(color: colors.contentPrimary),
            ),
            const SizedBox(height: SpacingScale.spaceSm), // 7dp ✓ var(--spacing/7)
            // Stars and category — gap: 8dp → spaceMd (9dp) gap
            Row(
              children: [
                // Figma renders 5-star row as image asset; using icons here
                for (int i = 0; i < starCount; i++)
                  Icon(
                    Icons.star_rounded,
                    size:  12, // Figma: 12px star container height
                    color: colors.feedbackWarning,
                  ),
                // Gap: 8dp — between spaceSm(7) and spaceMd(9); spaceMd as closest
                const SizedBox(width: SpacingScale.spaceMd),
                // P-Small: 13 / Regular / lh 21 ✓  var(--font/size/13, --font/lineheight/21)
                Text(
                  '$starCount star hotel',
                  style: TypographyScale.pSmall.copyWith(color: colors.contentSecondary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.spaceMd), // 9dp ✓ var(--spacing/9)
        // Location row — gap: var(--spacing/5) = spaceXs (5dp)
        Row(
          children: [
            // Figma: 12×12 location pin icon
            Icon(Icons.location_on_outlined, size: 12, color: colors.contentSecondary),
            const SizedBox(width: SpacingScale.spaceXs), // 5dp ✓ var(--spacing/5)
            Flexible(
              child: Text(
                location,
                overflow: TextOverflow.ellipsis,
                style: TypographyScale.pSmall.copyWith(color: colors.contentSecondary),
              ),
            ),
          ],
        ),
        if (offers.isNotEmpty) ...[
          const SizedBox(height: SpacingScale.spaceMd), // 9dp gap
          // Offers — gap: 8dp between items → spaceMd (9dp) as closest
          Wrap(
            spacing:    SpacingScale.spaceMd, // Gap: 8dp → 9dp
            runSpacing: SpacingScale.space2xs,
            children: [
              for (final offer in offers) _OfferItem(offer: offer, colors: colors),
            ],
          ),
        ],
      ],
    );
  }
}

class _OfferItem extends StatelessWidget {
  const _OfferItem({required this.offer, required this.colors});

  final String offer;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    // Gap: offer text color is #389E0D (Success/Green/500); feedbackPositive = successGreen400 (#52C41A)
    final green = colors.feedbackPositive;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Figma: 10×10 custom checkmark SVG
        Icon(Icons.check_circle_outline_rounded, size: 10, color: green),
        // Gap: 4dp — between space2xs(2) and spaceXs(5)
        const SizedBox(width: 4),
        // Gap: helper-text-01 (10px) → lbSmall (12px) as closest
        Text(
          offer,
          style: TypographyScale.lbSmall.copyWith(color: green),
        ),
      ],
    );
  }
}

// ─── Price Column (right, end-aligned) ───────────────────────────────────────

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.pricePerNight,
    required this.discountPercent,
    required this.taxesLabel,
    required this.colors,
  });

  final String pricePerNight;
  final int discountPercent;
  final String taxesLabel;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:       MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Discount badge — var(--primary/orange/background) = brandPrimary
        if (discountPercent > 0) ...[
          _DiscountBadge(percent: discountPercent, colors: colors),
          // Gap: 4dp — space2xs(2) is closest SpacingScale value
          const SizedBox(height: SpacingScale.space2xs),
        ],
        // Price + /night row — gap: 2dp = space2xs ✓
        Row(
          mainAxisSize:        MainAxisSize.min,
          crossAxisAlignment:  CrossAxisAlignment.baseline,
          textBaseline:        TextBaseline.alphabetic,
          children: [
            // Hd-Small: 17 / SemiBold / lh 23 ✓  var(--font/size/17, --font/weight/lexend/semibold)
            // Gap: color #262B30 (neutralGrey800) → contentPrimary (#121212)
            Text(
              pricePerNight,
              style: TypographyScale.hdSmall.copyWith(color: colors.contentPrimary),
            ),
            const SizedBox(width: SpacingScale.space2xs), // 2dp ✓
            // Gap: captions-01 (12px/lh16) → lbSmall (12px/lh19); lh differs
            // Gap: color #8C9AAA (neutralGrey600) → contentSecondary (#4B545E)
            Text(
              '/night',
              style: TypographyScale.lbSmall.copyWith(color: colors.contentSecondary),
            ),
          ],
        ),
        // Gap: 4dp — space2xs(2) as closest
        const SizedBox(height: SpacingScale.space2xs),
        // P-Small: 13 / Regular / lh 21 ✓
        // Gap: color #8C9AAA → contentSecondary
        Text(
          taxesLabel,
          style: TypographyScale.pSmall.copyWith(color: colors.contentSecondary),
        ),
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent, required this.colors});

  final int percent;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:        colors.brandPrimary, // var(--primary/orange/background) ✓
        borderRadius: BorderRadius.circular(RadiusTokens.r20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.spaceSm, // 7dp ✓ var(--spacing/7)
          vertical:   SpacingScale.spaceXs, // 5dp ✓ var(--spacing/5)
        ),
        // Gap: helper-text-01 (10px) → lbSmall (12px) as closest
        child: Text(
          '$percent% off',
          style: TypographyScale.lbSmall.copyWith(color: colors.backgroundPrimary),
        ),
      ),
    );
  }
}

// ─── Rewards Bar ─────────────────────────────────────────────────────────────

class _RewardsBar extends StatelessWidget {
  const _RewardsBar({required this.rewardsAmount, required this.colors});

  final String rewardsAmount;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    // Gap: rewards text color #D48806 (alertYellow500) → feedbackWarning (alertYellow400 #FAAD14)
    final amber = colors.feedbackWarning;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:        colors.backgroundPrimary, // var(--surface/background/primary) ✓
        borderRadius: BorderRadius.circular(RadiusTokens.r8), // var(--radius/8) ✓
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SpacingScale.spaceSm, // 7dp ✓ var(--spacing/7)
        ),
        // Figma uses px-[71px] to visually center; using MainAxisAlignment.center instead
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // P-Small: 13 / Regular / lh 21 ✓
            Text(
              'Earning $rewardsAmount rewards back',
              style: TypographyScale.pSmall.copyWith(color: amber),
            ),
            const SizedBox(width: SpacingScale.space2xs), // 2dp ✓
            // Figma: arrow-down-s-line SVG (16×16)
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: amber),
          ],
        ),
      ),
    );
  }
}
