import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

/// Amenity item shown in [StaysPropertyCard].
class StaysAmenity {
  const StaysAmenity({required this.label, required this.icon});

  /// Short label shown inside the chip, e.g. "Kitchen".
  final String label;

  /// Icon widget — typically a 16×16 asset or `Icon`.
  final Widget icon;
}

/// Stays property summary card — 343dp wide.
///
/// Shows a property image with a rating overlay pill, property name,
/// location, guest capacity, amenity chips, and a "View all amenities"
/// action link. Used in search results and property listing screens.
///
/// ## Typography
/// | Element | Figma style | Static |
/// |---|---|---|
/// | Property title | Hd-Small | `TypographyScale.hdSmall` |
/// | Location / guest details | P-Small | `TypographyScale.pSmall` |
/// | Rating score | Shd-Small | `TypographyScale.shdSmall` |
/// | Rating label ("Excellent") | P-Small | `TypographyScale.pSmall` |
/// | Rating count / amenity text | P-extra-small / captions-01 | `TypographyScale.lbSmall` *(gap)* |
///
/// ## Known token gaps
/// - `#262B30` (neutralGrey800, Text/High emphasis) → `contentPrimary`
/// - `#8C9AAA` (neutralGrey600, Text/Low emphasis) → `contentSecondary`
/// - `#388CEB` (blue link, no DS token) → `brandPrimary`
/// - `--primary/scapia/000` (star badge bg) → `ColorPrimitives.primaryScapia000` (Tier 1)
/// - P-extra-small (10px/400/15lh) → `lbSmall` (12px)
/// - captions-01 (12px/400/16lh) → `lbSmall` (12px/19lh)
/// - 4dp gap → `spaceXs` (5dp)
/// - `--border/2` (border width 2dp) → hardcoded 2.0 (no BorderTokens yet)
class StaysPropertyCard extends StatelessWidget {
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

  /// URL of the property hero image.
  final String imageUrl;

  /// Full property name, e.g. "Casa Belvedere Luxury Villas".
  final String propertyName;

  /// Location string, e.g. "Kasauli, Himachal Pradesh".
  final String location;

  /// Guest capacity string, e.g. "6 guests • 2 rooms".
  final String guestDetails;

  /// Amenities to display. At most 3 are shown; the rest are counted in [additionalAmenitiesCount].
  final List<StaysAmenity> amenities;

  /// Count of amenities not shown in chips, displayed as "+N". `0` hides the chip.
  final int additionalAmenitiesCount;

  /// Rating score, e.g. 4.2. `null` hides the rating pill entirely.
  final double? ratingScore;

  /// Rating verdict label, e.g. "Excellent".
  final String? ratingLabel;

  /// Rating count label, e.g. "2.4k ratings".
  final String? ratingCount;

  /// Called when "View all amenities" is tapped. `null` hides the link.
  final VoidCallback? onViewAllAmenities;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  static const double _cardWidth   = 343;
  static const double _imageHeight = 143;
  // Gap: --border/2 (2dp border width) — no BorderTokens equivalent yet
  static const double _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorScale>()!;

    return SizedBox(
      width: _cardWidth,
      child: Semantics(
        label:   propertyName,
        button:  onTap != null,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color:        colors.backgroundPrimary,
              borderRadius: BorderRadius.circular(RadiusTokens.r20),
              border:       Border.all(
                color: colors.borderOpaque,
                width: _borderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
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
                _DescriptionSection(
                  propertyName:            propertyName,
                  location:                location,
                  guestDetails:            guestDetails,
                  amenities:               amenities,
                  additionalAmenitiesCount: additionalAmenitiesCount,
                  onViewAllAmenities:      onViewAllAmenities,
                  colors:                  colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Image section ─────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.imageUrl,
    required this.ratingScore,
    required this.ratingLabel,
    required this.ratingCount,
    required this.colors,
  });

  final String     imageUrl;
  final double?    ratingScore;
  final String?    ratingLabel;
  final String?    ratingCount;
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
            fit:          BoxFit.cover,
            errorBuilder: (ctx, err, stack) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [colors.backgroundTertiary, colors.backgroundSecondary],
                ),
              ),
            ),
          ),
          if (ratingScore != null)
            Positioned(
              // Gap: Figma left=11dp — no token; spaceMdLg (13dp) is closest
              left:   SpacingScale.spaceMdLg,
              bottom: SpacingScale.spaceMd, // 9dp ✓
              child:  _RatingPill(
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

// ─── Rating pill ───────────────────────────────────────────────────────────

class _RatingPill extends StatelessWidget {
  const _RatingPill({
    required this.score,
    required this.label,
    required this.count,
    required this.colors,
  });

  final double     score;
  final String?    label;
  final String?    count;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.r20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Gap: rgba(0,0,0,0.4) overlay — no Tier 2 overlay token
            color:        const Color(0x66000000), // ds-lint-ignore: no_hardcoded_color — overlay bg, no Tier 2 token yet
            borderRadius: BorderRadius.circular(RadiusTokens.r20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingScale.spaceSm, // 7dp ✓ var(--spacing/7)
              vertical:   SpacingScale.spaceXs, // 5dp ✓ var(--spacing/5)
            ),
            child: Row(
              mainAxisSize:       MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _RatingScoreBadge(score: score, colors: colors),
                const SizedBox(width: SpacingScale.spaceXs), // 5dp ✓ var(--spacing/5)
                if (label != null || count != null)
                  Column(
                    mainAxisSize:       MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (label != null)
                        // P-Small: 13/Regular/21 ✓ — color: --surface/content/primary on dark bg
                        Text(
                          label!,
                          style: TypographyScale.pSmall.copyWith(
                            color: colors.backgroundPrimary,
                          ),
                        ),
                      if (count != null)
                        // Gap: P-extra-small (10px/400/15lh) not in TypographyScale → lbSmall
                        Text(
                          count!,
                          style: TypographyScale.lbSmall.copyWith(
                            color: colors.contentSecondary, // --surface/content/secondary ✓
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

  final double     score;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Gap: --primary/scapia/000 (#FFEAE0) — Tier 1 only, no Tier 2 alias yet
        color:        ColorPrimitives.primaryScapia000, // ds-lint-ignore: no_tier1_in_widgets — star badge tint, no Tier 2 alias yet
        borderRadius: BorderRadius.circular(RadiusTokens.r24),
      ),
      child: Padding(
        // Figma: px=5, pt=3, pb=4 — sub-token values from spec
        padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 4),
        child: Row(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, size: 10, color: colors.brandPrimary),
            const SizedBox(width: 3), // Figma: 3dp gap, sub-token value
            // Shd-Small: 15/500/23 ✓
            // Gap: color #262B30 (neutralGrey800, Text/High emphasis) → contentPrimary
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

// ─── Description section ───────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.propertyName,
    required this.location,
    required this.guestDetails,
    required this.amenities,
    required this.additionalAmenitiesCount,
    required this.onViewAllAmenities,
    required this.colors,
  });

  final String            propertyName;
  final String            location;
  final String            guestDetails;
  final List<StaysAmenity> amenities;
  final int               additionalAmenitiesCount;
  final VoidCallback?     onViewAllAmenities;
  final ColorScale        colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingScale.spaceLg), // 15dp ✓ var(--spacing/15)
      child: Column(
        mainAxisSize:       MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PropertyInfo(
            propertyName: propertyName,
            location:     location,
            guestDetails: guestDetails,
            colors:       colors,
          ),
          const SizedBox(height: SpacingScale.spaceXl), // 21dp ✓ var(--spacing/21)
          _AmenitiesRow(
            amenities:       amenities,
            additionalCount: additionalAmenitiesCount,
            colors:          colors,
          ),
          if (onViewAllAmenities != null) ...[
            const SizedBox(height: SpacingScale.spaceXl), // 21dp ✓ var(--spacing/21)
            Semantics(
              button: true,
              label:  'View all amenities',
              child:  GestureDetector(
                onTap: onViewAllAmenities,
                child: Text(
                  'View all amenities',
                  style: TypographyScale.pSmall.copyWith(
                    // Gap: #388CEB (blue link) — no Tier 2 link/action token; brandPrimary per decision
                    color: colors.brandPrimary,
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

// ─── Property info ─────────────────────────────────────────────────────────

class _PropertyInfo extends StatelessWidget {
  const _PropertyInfo({
    required this.propertyName,
    required this.location,
    required this.guestDetails,
    required this.colors,
  });

  final String     propertyName;
  final String     location;
  final String     guestDetails;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:       MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hd-Small: 17/600/23 ✓
        // Gap: #262B30 (neutralGrey800, Text/High emphasis) → contentPrimary
        Text(
          propertyName,
          style: TypographyScale.hdSmall.copyWith(color: colors.contentPrimary),
        ),
        const SizedBox(height: SpacingScale.spaceSm), // 7dp ✓ var(--spacing/7)
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size:  12,
              color: colors.contentSecondary,
            ),
            const SizedBox(width: SpacingScale.spaceXs), // 5dp ✓ var(--spacing/5)
            Flexible(
              child: Text(
                location,
                overflow: TextOverflow.ellipsis,
                style:    TypographyScale.pSmall.copyWith(
                  // Gap: #8C9AAA (neutralGrey600, Text/Low emphasis) → contentSecondary
                  color: colors.contentSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.spaceSm), // 7dp ✓
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size:  12,
              color: colors.contentSecondary,
            ),
            const SizedBox(width: SpacingScale.spaceXs), // 5dp ✓ var(--spacing/5)
            // P-Small ✓ + --surface/content/secondary ✓
            Text(
              guestDetails,
              style: TypographyScale.pSmall.copyWith(color: colors.contentSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Amenities row ─────────────────────────────────────────────────────────

class _AmenitiesRow extends StatelessWidget {
  const _AmenitiesRow({
    required this.amenities,
    required this.additionalCount,
    required this.colors,
  });

  final List<StaysAmenity> amenities;
  final int                additionalCount;
  final ColorScale         colors;

  @override
  Widget build(BuildContext context) {
    final visible = amenities.take(3).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          _AmenityChip(amenity: visible[i], colors: colors),
          // Gap: 4dp between chips — no token; spaceXs (5dp) is closest
          const SizedBox(width: SpacingScale.spaceXs),
        ],
        if (additionalCount > 0)
          _MoreAmenitiesChip(count: additionalCount, colors: colors),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.amenity, required this.colors});

  final StaysAmenity amenity;
  final ColorScale   colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:        colors.backgroundSecondary, // #F1F6FB ✓
        borderRadius: BorderRadius.circular(RadiusTokens.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.spaceMdLg, // 13dp ✓ var(--spacing/13)
          vertical:   SpacingScale.spaceXs,   // 5dp ✓ var(--spacing/5)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: amenity.icon),
            // Gap: 4dp icon→label — no token; spaceXs (5dp) closest
            const SizedBox(width: SpacingScale.spaceXs),
            // Gap: captions-01 (12px/Regular/16lh) → lbSmall (12px/Regular/19lh)
            // Gap: #262B30 (neutralGrey800) → contentPrimary
            Text(
              amenity.label,
              style: TypographyScale.lbSmall.copyWith(color: colors.contentPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreAmenitiesChip extends StatelessWidget {
  const _MoreAmenitiesChip({required this.count, required this.colors});

  final int        count;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:        colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(RadiusTokens.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.spaceMdLg,
          vertical:   SpacingScale.spaceXs,
        ),
        // Gap: helper-text-01 (10px) → lbSmall; #8C9AAA → contentSecondary
        child: Text(
          '+$count',
          style: TypographyScale.lbSmall.copyWith(color: colors.contentSecondary),
        ),
      ),
    );
  }
}
