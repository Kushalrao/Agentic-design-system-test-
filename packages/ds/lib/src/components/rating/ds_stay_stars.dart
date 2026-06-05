import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

import '../../icons/scapia_icons.dart';

/// Stays star-classification row.
///
/// Renders [starCount] filled star icons followed by an optional [label].
/// Use on property cards, search results, and detail pages to show the
/// hotel star classification.
class DsStayStars extends StatelessWidget {
  /// Creates a stay-stars row.
  const DsStayStars({
    super.key,
    required this.starCount,
    this.label,
  }) : assert(starCount >= 1 && starCount <= 5,
            'starCount must be between 1 and 5');

  /// Number of stars to display (1–5). Figma default: 5.
  final int starCount;

  /// Optional label shown after the stars, e.g. `"5 star hotel"`.
  /// `null` hides the label — renders stars only.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorScale>()!;
    return Semantics(
      label: label != null
          ? '$starCount star hotel — $label'
          : '$starCount star hotel',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stars row — itemSpacing 2 dp (Spacing/2 → space2xs) ✓
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < starCount; i++) ...[
                if (i > 0) const SizedBox(width: SpacingScale.space2xs), // 2 dp ✓
                SvgPicture.asset(
                  ScapiaIcons.staystarsStaystars11px,
                  width: 11,
                  height: 11,
                  // Brand/Dark (VariableID:334:10807) → colors.brandDark ✓
                  colorFilter: ColorFilter.mode(
                    colors.brandDark,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ],
          ),
          // Label — visible when non-null (Label#489:3 BOOLEAN)
          if (label != null) ...[
            const SizedBox(width: SpacingScale.spaceSm), // 7 dp (Spacing/7) ✓
            Text(
              label!,
              style: TypographyScale.lbSmall.copyWith(
                // Surface/Content/Secondary (VariableID:334:10803) → contentSecondary ✓
                color: colors.contentSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
