import 'package:flutter/material.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

/// The three visual states of an [DsApBenefits] card.
enum DsApBenefitsState {
  /// Benefit is available but not yet activated.
  active,

  /// Benefit has been activated by the user.
  activated,

  /// Benefit is unavailable / locked.
  inactive,
}

/// AP benefit card — 166×185 dp.
///
/// Shows a benefit tile with an illustration area, heading, description,
/// and a reward chip. Three visual states: [DsApBenefitsState.active],
/// [DsApBenefitsState.activated] (green border + "Active" badge), and
/// [DsApBenefitsState.inactive] ("Inactive" badge).
class DsApBenefits extends StatelessWidget {
  /// Creates a benefit card.
  const DsApBenefits({
    super.key,
    required this.heading,
    required this.rewardText,
    required this.state,
    this.description = 'Activate with one tap',
    this.onTap,
  });

  /// Primary heading, e.g. "Free shopping". Maps to Figma `Heading` property.
  final String heading;

  /// Reward chip text, e.g. "Get ₹1,000 back". Maps to Figma `Benefits` property.
  final String rewardText;

  /// Visual state of the card.
  final DsApBenefitsState state;

  /// Subtitle shown below the heading.
  final String description;

  /// Called when the card is tapped. `null` disables tap feedback.
  final VoidCallback? onTap;

  static const double _cardWidth   = 166; // Figma: State=Active w=166
  static const double _cardHeight  = 185; // Figma: State=Active h=185
  static const double _imageSize   = 66;  // Figma: Image Container 66×66

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorScale>()!;

    final bool showActiveTag   = state == DsApBenefitsState.activated;
    final bool showInactiveTag = state == DsApBenefitsState.inactive;

    return Semantics(
      button: onTap != null,
      label: '$heading — $rewardText — ${state.name}',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _cardWidth,
          height: _cardHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              // Gap: #E0EFFF (VariableID:557:292) — not in Color Semantics Tier 2;
              // raw literal per user decision.
              color: const Color(0xFFE0EFFF), // ds-lint-ignore: no_hardcoded_color
              borderRadius: BorderRadius.circular(RadiusTokens.r16),
              // [D] Border: only in Activated state
              border: state == DsApBenefitsState.activated
                  ? Border.all(
                      width: 2.0, // Gap: Border/2 = 2dp; no BorderTokens class yet
                      // Gap: #389E0D (successGreen500) → feedbackPositive per color.md
                      color: colors.feedbackPositive,
                    ) // ds-lint-ignore: no_bare_border
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.r16),
              child: Stack(
                children: [
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(SpacingScale.spaceMdLg), // 13dp ✓
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Illustration area — Gap: shopping bag illustration
                        // export from Figma node 550:5857 once assets pipeline is ready.
                        const SizedBox(
                          width:  _imageSize,
                          height: _imageSize,
                        ),

                        const SizedBox(height: SpacingScale.spaceMd), // 9dp — SPACE_BETWEEN gap ✓

                        // Text + chip — fixed 84dp height matching Figma Container (550:5913).
                        // OverflowBox + ClipRect: permits child to exceed 84dp without a
                        // layout error; ClipRect hides any overflow visually. Needed because
                        // system fonts in test env render larger than Lexend Deca.
                        SizedBox(
                          height: 84,
                          child: ClipRect(
                            child: OverflowBox(
                              maxHeight: double.infinity,
                              alignment: Alignment.topLeft,
                              child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading + description
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  heading,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TypographyScale.shdSmall.copyWith(
                                    color: colors.contentPrimary, // contentPrimary ✓
                                  ),
                                ),
                                const SizedBox(height: SpacingScale.space2xs), // 2dp ✓
                                Text(
                                  description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TypographyScale.pSmall.copyWith(
                                    color: colors.contentSecondary, // contentSecondary ✓
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: SpacingScale.spaceMd), // 9dp ✓

                            // Reward chip
                            _RewardChip(
                              text:   rewardText,
                              colors: colors,
                            ),
                          ],
                        ),
                        ))), // end OverflowBox + ClipRect + SizedBox(84)
                      ],
                    ),
                  ),

                  // [D] Activated badge — absolute top-right
                  if (showActiveTag)
                    Positioned(
                      top:   0,
                      right: 0,
                      child: _StateTag(
                        label:    'Active',
                        bgColor:  colors.feedbackPositive, // Gap: #389E0D → feedbackPositive per color.md
                        textColor: colors.backgroundPrimary,
                      ),
                    ),

                  // [D] Inactive badge — absolute top-right
                  if (showInactiveTag)
                    Positioned(
                      top:   0,
                      right: 0,
                      child: _StateTag(
                        label:    'Inactive',
                        bgColor:  colors.backgroundTertiary, // backgroundTertiary ✓
                        textColor: colors.contentPrimary,
                      ),
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

// ─── Reward chip ───────────────────────────────────────────────────────────────

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.text, required this.colors});

  final String     text;
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Gap: LinearGradient — #B5D5FA (VariableID:557:494) → transparent #E0EFFF;
        // no Tier 2 tokens for either stop; raw per user decision.
        gradient: const LinearGradient( // ds-lint-ignore: no_hardcoded_color
          begin: Alignment.centerLeft,
          end:   Alignment.centerRight,
          colors: [
            Color(0xFFB5D5FA), // ds-lint-ignore: no_hardcoded_color — Gap: VariableID:557:494, no Tier 2 token
            Color(0x00E0EFFF), // ds-lint-ignore: no_hardcoded_color — Gap: VariableID:557:292, no Tier 2 token
          ],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.r8), // Radius/8 ✓
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.spaceSm), // 7dp ✓
        child: Text(
          text,
          style: TypographyScale.pExtraSmall.copyWith(
            color: colors.contentPrimary, // contentPrimary ✓
          ),
        ),
      ),
    );
  }
}

// ─── State tag (Active / Inactive) ─────────────────────────────────────────────

class _StateTag extends StatelessWidget {
  const _StateTag({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  final String label;
  final Color  bgColor;
  final Color  textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(RadiusTokens.r8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.spaceMd,   // 9dp ✓
          vertical:   SpacingScale.space2xs,  // 2dp ✓
        ),
        child: Text(
          label,
          style: TypographyScale.pSmall.copyWith(color: textColor),
        ),
      ),
    );
  }
}
