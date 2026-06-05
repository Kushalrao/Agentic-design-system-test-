import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

import '../../icons/scapia_icons.dart';

/// Scapia score rating badge — two states driven by [label] nullability.
///
/// Pass [label] + [count] for the expanded pill (score + verdict + count).
/// Omit [label] for the compact pill (score badge only).
///
/// Designed to sit over image content (dark blurred overlay).
class DsScapiaScore extends StatelessWidget {
  /// Creates a Scapia score badge.
  const DsScapiaScore({
    super.key,
    required this.score,
    this.label,
    this.count,
  });

  /// Numeric score, e.g. `4.2`.
  final double score;

  /// Rating verdict, e.g. `"Excellent"`. When `null`, renders compact (score-only) state.
  final String? label;

  /// Rating count, e.g. `"2.4k ratings"`. Only shown when [label] is non-null.
  final String? count;

  bool get _hasLabel => label != null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorScale>()!;
    return Semantics(
      label: _hasLabel
          ? 'Rating: ${score.toStringAsFixed(1)} — $label${count != null ? ", $count" : ""}'
          : 'Rating: ${score.toStringAsFixed(1)}',
      child: ClipRRect(
        // [D] radius differs: r12 with label, r8 without
        borderRadius: BorderRadius.circular(
          _hasLabel ? RadiusTokens.r12 : RadiusTokens.r8,
        ),
        child: BackdropFilter(
          // Figma: BACKGROUND_BLUR radius=44 — no token, exact value
          filter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
          child: DecoratedBox(
            decoration: BoxDecoration(
              // Gap: rgba(0,0,0,0.4) — no Tier 2 overlay token; using Color(0x66000000) per stays_srp_card.md
              color: const Color(0x66000000), // ds-lint-ignore: no_hardcoded_color — overlay bg, no Tier 2 token
              borderRadius: BorderRadius.circular(
                _hasLabel ? RadiusTokens.r12 : RadiusTokens.r8,
              ),
            ),
            child: Padding(
              // [D] padding: L:5 R:9 T/B:2 with label, all-zero without
              padding: _hasLabel
                  ? const EdgeInsets.only(
                      left:   SpacingScale.spaceXs,  // 5 dp ✓ Spacing/5
                      right:  SpacingScale.spaceMd,  // 9 dp ✓ Spacing/9
                      top:    SpacingScale.space2xs, // 2 dp ✓ Spacing/2
                      bottom: SpacingScale.space2xs, // 2 dp ✓ Spacing/2
                    )
                  : EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ScoreBadge(score: score, colors: colors),
                  if (_hasLabel) ...[
                    // [D] gap: 5 dp with label, 0 without
                    const SizedBox(width: SpacingScale.spaceXs), // 5 dp ✓ Spacing/5
                    _LabelColumn(
                      label: label!,
                      count: count,
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Score Badge ───────────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.colors});

  final double score;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Gap: #FFEAE0 (primaryScapia000) — Tier 1 only, no Tier 2 alias yet; per stays_srp_card.md
        color: ColorPrimitives.primaryScapia000, // ds-lint-ignore: no_tier1_in_widgets — score badge tint, no Tier 2 alias
        borderRadius: BorderRadius.circular(RadiusTokens.r8), // Radius/8 ✓
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.spaceXs,  // 5 dp ✓ Spacing/5
          vertical:   SpacingScale.space2xs, // 2 dp ✓ Spacing/2
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ScapiaIcons.scapiaScoreScapiaScore11px,
              width: 11,
              height: 11,
            ),
            const SizedBox(width: SpacingScale.space2xs), // 2 dp ✓ Spacing/2 (icon→text gap)
            Text(
              score.toStringAsFixed(1),
              style: TypographyScale.pExtraSmall.copyWith(
                color: colors.brandPrimary, // Brand/Primary → colors.brandPrimary ✓
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Label Column ──────────────────────────────────────────────────────────────

class _LabelColumn extends StatelessWidget {
  const _LabelColumn({
    required this.label,
    required this.count,
    required this.colors,
  });

  final String label;
  final String? count;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      // itemSpacing: 0 — Spacing/0; no SizedBox needed
      children: [
        // Rating verdict — Surface/Content/Primary in dark overlay context = white
        Text(
          label,
          style: TypographyScale.pExtraSmall.copyWith(
            color: colors.backgroundPrimary, // white on dark overlay ✓
          ),
        ),
        if (count != null)
          Text(
            count!,
            style: TypographyScale.pExtraSmall.copyWith(
              color: colors.contentTertiary, // Surface/Content/Tertiary ✓
            ),
          ),
      ],
    );
  }
}
