import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

/// Data for a single amenity chip inside [StaysPropertyCard].
class StaysAmenity {
  /// Creates an amenity entry.
  const StaysAmenity({required this.label, required this.icon});

  /// Display label, e.g. "Kitchen".
  final String label;

  /// Icon rendered before the label. Use a 16×16 [Icon].
  final Widget icon;
}

/// Property detail card — 343 dp wide.
///
/// Displays a stays property listing with a hero image, rating overlay,
/// property name, location, guest configuration, amenity chips, and a
/// "View all amenities" link. Use on property detail entry points and
/// curated recommendation surfaces.
class StaysPropertyCard extends StatelessWidget {
  /// Creates a property card.
  const StaysPropertyCard({
    super.key,
    required this.imageUrl,
    required this.propertyName,
    required this.location,
    required this.guestDetails,
    required this.amenities,
    this.additionalAmenitiesCount = 0,
    this.ratingScore,
    this.ratingLabel,
    this.ratingCount,
    this.onViewAllAmenities,
    this.onTap,
  });

  /// URL of the hero property image.
  final String imageUrl;

  /// Property name, e.g. "Casa Belvedere Luxury Villas".
  final String propertyName;

  /// Location string, e.g. "Kasauli, Himachal Pradesh".
  final String location;

  /// Guest configuration string, e.g. "6 guests • 2 rooms".
  final String guestDetails;

  /// Amenity chips to display in the row.
  final List<StaysAmenity> amenities;

  /// Count of additional amenities not shown as chips. `0` hides the overflow chip.
  final int additionalAmenitiesCount;

  /// Rating score, e.g. 4.2. `null` hides the rating pill entirely.
  final double? ratingScore;

  /// Short rating verdict, e.g. "Excellent".
  final String? ratingLabel;

  /// Rating count label, e.g. "2.4k ratings".
  final String? ratingCount;

  /// Called when "View all amenities" is tapped. `null` hides the link row.
  final VoidCallback? onViewAllAmenities;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  static const double _cardWidth   = 343;
  // Fix 1: Figma Ratings Background node 2675:5228 has fixed height=143 dp.
  // Previous value of 196 was estimated from screenshot proportion — wrong.
  static const double _imageHeight = 143;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorScale>()!;
    return Semantics(
      button:    onTap != null,
      label:     propertyName,
      child: SizedBox(
        width: _cardWidth,
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.r20),
            child: ColoredBox(
              color: colors.backgroundPrimary,
              child: Column(
                mainAxisSize:       MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImageSection(
                    imageUrl:    imageUrl,
                    ratingScore: ratingScore,
                    ratingLabel: ratingLabel,
                    ratingCount: ratingCount,
                    colors:      colors,
                  ),
                  _ContentSection(
                    propertyName:             propertyName,
                    location:                 location,
                    guestDetails:             guestDetails,
                    amenities:                amenities,
                    additionalAmenitiesCount: additionalAmenitiesCount,
                    onViewAllAmenities:       onViewAllAmenities,
                    colors:                   colors,
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

// ─── Image Section ─────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.imageUrl,
    required this.ratingScore,
    required this.ratingLabel,
    required this.ratingCount,
    required this.colors,
  });

  final String imageUrl;
  final double? ratingScore;
  final String? ratingLabel;
  final String? ratingCount;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: StaysPropertyCard._imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, _) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [colors.backgroundTertiary, colors.backgroundSecondary],
                ),
              ),
            ),
          ),
          if (ratingScore != null)
            Positioned(
              // Fix 2: pill.x - card.x = 11 dp; no SpacingScale token for 11 dp
              left:   11,
              // Fix 3: image bottom - pill bottom = 9 dp → spaceMd (exact match)
              bottom: SpacingScale.spaceMd,
              child: _RatingPill(
                score:  ratingScore!,
                label:  ratingLabel,
                count:  ratingCount,
                colors: colors,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Rating Pill ───────────────────────────────────────────────────────────────

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
      // Fix 6: Figma pill cornerRadius=20 dp → r20 (was r16)
      borderRadius: BorderRadius.circular(RadiusTokens.r20),
      child: BackdropFilter(
        // Fix 7: Figma BACKGROUND_BLUR effect radius=4 (was sigmaX:2)
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Gap: rgba(0,0,0,0.4) — no Tier 2 overlay token
            color:        const Color(0x66000000), // ds-lint-ignore: no_hardcoded_color — overlay bg, no Tier 2 token
            // Fix 6 (continued): same radius as ClipRRect
            borderRadius: BorderRadius.circular(RadiusTokens.r20),
          ),
          child: Padding(
            // Fix 4: Figma pill padding h=7 dp (spaceSm), v=5 dp (spaceXs)
            // Previously used asymmetric estimated values (l:4, r:6, t:4, b:4)
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingScale.spaceSm,  // 7 dp ✓
              vertical:   SpacingScale.spaceXs,  // 5 dp ✓
            ),
            child: Row(
              mainAxisSize:        MainAxisSize.min,
              crossAxisAlignment:  CrossAxisAlignment.center,
              children: [
                _RatingScoreBadge(score: score, colors: colors),
                // Fix 5: itemSpacing between Rating Icon and Rating Details = 5 dp (spaceXs)
                const SizedBox(width: SpacingScale.spaceXs), // 5 dp ✓
                if (label != null || count != null)
                  Column(
                    mainAxisSize:        MainAxisSize.min,
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      if (label != null)
                        // Fix 8: Rating Title uses P-Small (13sp w400) not lbSmall (12sp)
                        Text(
                          label!,
                          style: TypographyScale.pSmall.copyWith(
                            color: colors.backgroundPrimary,
                          ),
                        ),
                      if (count != null)
                        // Gap: P-extra-small (10sp) has no DS token; lbSmall (12sp) is closest
                        Text(
                          count!,
                          style: TypographyScale.lbSmall.copyWith(
                            // rgba(255,255,255,0.85) — no Tier 2 opacity-on-white token
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
        // Gap: #FFF2EC (primaryScapia000) — Tier 1 only, no Tier 2 alias yet
        color:        ColorPrimitives.primaryScapia000, // ds-lint-ignore: no_tier1_in_widgets — star badge tint, no Tier 2 alias
        borderRadius: BorderRadius.circular(RadiusTokens.r24),
      ),
      child: Padding(
        // Sub-token values from Figma spec (px:5, pt:3, pb:4 — no SpacingScale match)
        padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 4),
        child: Row(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, size: 10, color: colors.brandPrimary),
            const SizedBox(width: 3), // 3 dp — sub-token value, no SpacingScale match
            // Fix 9: Rating Score uses Shd-Small (15sp w500) not pSmall+w600 (13sp w600)
            // color: #262B30 → contentPrimary
            Text(
              score.toStringAsFixed(1),
              style: TypographyScale.shdSmall.copyWith(
                color: colors.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Content Section ───────────────────────────────────────────────────────────

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.propertyName,
    required this.location,
    required this.guestDetails,
    required this.amenities,
    required this.additionalAmenitiesCount,
    required this.onViewAllAmenities,
    required this.colors,
  });

  final String propertyName;
  final String location;
  final String guestDetails;
  final List<StaysAmenity> amenities;
  final int additionalAmenitiesCount;
  final VoidCallback? onViewAllAmenities;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Fix 10: Description Section padding=15 dp (spaceLg) on all sides
      // Previously used spaceMdLg=13 dp — wrong token
      padding: const EdgeInsets.all(SpacingScale.spaceLg), // 15 dp ✓
      child: Column(
        mainAxisSize:       MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property name — Hd-Small; Gap: #262B30 (neutralGrey800) → contentPrimary
          Text(
            propertyName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TypographyScale.hdSmall.copyWith(
              color: colors.contentPrimary,
            ),
          ),
          // Property Info itemSpacing = 7 dp (between Title / Location / Guest)
          const SizedBox(height: SpacingScale.spaceSm), // 7 dp ✓
          // Location row
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size:  12, // Figma location icon frame = 12×14 dp
                color: colors.contentSecondary,
              ),
              const SizedBox(width: SpacingScale.spaceXs), // 5 dp ✓
              Expanded(
                // Gap: #8C9AAA (neutralGrey600) → contentSecondary
                child: Text(
                  location,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyScale.pSmall.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.spaceSm), // 7 dp ✓
          // Guest details row
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size:  12, // Figma people icon frame = 12×12 dp
                color: colors.contentSecondary,
              ),
              const SizedBox(width: SpacingScale.spaceXs), // 5 dp ✓
              Expanded(
                // Gap: #8C9AAA (neutralGrey600) → contentSecondary
                child: Text(
                  guestDetails,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyScale.pSmall.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (amenities.isNotEmpty) ...[
            // Fix 11: Description Section itemSpacing = 21 dp (spaceXl)
            // between Property Info and Amenities Section (was spaceSm=7 dp)
            const SizedBox(height: SpacingScale.spaceXl), // 21 dp ✓
            _AmenitiesRow(
              amenities:       amenities,
              additionalCount: additionalAmenitiesCount,
              colors:          colors,
            ),
          ],
          if (onViewAllAmenities != null) ...[
            // Fix 12: Description Section itemSpacing = 21 dp (spaceXl)
            // between Amenities Section and View All text (was spaceSm=7 dp)
            const SizedBox(height: SpacingScale.spaceXl), // 21 dp ✓
            Semantics(
              button: true,
              label:  'View all amenities',
              child: GestureDetector(
                onTap: onViewAllAmenities,
                child: Text(
                  'View all amenities',
                  style: TypographyScale.pSmall.copyWith(
                    color: colors.brandDark,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Amenities Row ─────────────────────────────────────────────────────────────

class _AmenitiesRow extends StatelessWidget {
  const _AmenitiesRow({
    required this.amenities,
    required this.additionalCount,
    required this.colors,
  });

  final List<StaysAmenity> amenities;
  final int additionalCount;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < amenities.length; i++) ...[
            // Fix 14: Amenities Section itemSpacing between chips = 4 dp
            // No SpacingScale token for 4 dp — raw literal
            if (i > 0) const SizedBox(width: 4), // 4 dp — sub-token gap, no match
            _AmenityChip(amenity: amenities[i], colors: colors),
          ],
          if (additionalCount > 0) ...[
            const SizedBox(width: 4), // 4 dp — same inter-chip gap
            _MoreChip(count: additionalCount, colors: colors),
          ],
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.amenity, required this.colors});

  final StaysAmenity amenity;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:        colors.backgroundSecondary, // #F1F6FB ✓
        // Gap: Border/1 variable = 1 dp; no BorderTokens class yet
        border:       Border.all(width: 1.0, color: colors.borderOpaque), // ds-lint-ignore: no_bare_border
        borderRadius: BorderRadius.circular(RadiusTokens.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.spaceMdLg, // 13 dp ✓
          vertical:   SpacingScale.spaceXs,   // 5 dp ✓
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(size: 16, color: colors.contentSecondary),
              child: amenity.icon,
            ),
            // Fix 15: Amenity Info itemSpacing icon-to-label = 4 dp; no token match
            const SizedBox(width: 4), // 4 dp — sub-token gap
            // Gap: #262B30 (neutralGrey800) → contentPrimary
            Text(
              amenity.label,
              style: TypographyScale.shdSmall.copyWith(
                color: colors.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.count, required this.colors});

  final int count;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:        colors.backgroundSecondary,
        // Gap: Border/1 variable = 1 dp; no BorderTokens class yet
        border:       Border.all(width: 1.0, color: colors.borderOpaque), // ds-lint-ignore: no_bare_border
        borderRadius: BorderRadius.circular(RadiusTokens.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.spaceMdLg, // 13 dp ✓ (matches amenity chip)
          vertical:   SpacingScale.spaceXs,   // 5 dp ✓
        ),
        child: Text(
          '+$count',
          style: TypographyScale.shdSmall.copyWith(
            color: colors.contentSecondary,
          ),
        ),
      ),
    );
  }
}
