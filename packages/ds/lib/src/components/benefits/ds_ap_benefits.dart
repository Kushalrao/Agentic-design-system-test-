import 'package:flutter/material.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

/// The four benefit card themes driven by `Base • AP Cards` variable modes.
enum DsApBenefitsType {
  /// Shopping benefit — blue palette (#E0EFFF / #B5D5FA).
  shop,

  /// Dining/meal benefit — yellow palette (#FFFBE6 / #FFE58F).
  meal,

  /// Spa benefit — green palette (#F6FFED / #B7EB8F).
  spa,

  /// Airport lounge benefit — warm orange palette (#FFEAE0 / #FECBB3).
  lounge,
}

/// The three visual states of an [DsApBenefits] card.
enum DsApBenefitsState {
  /// Benefit available, not yet activated.
  active,

  /// Benefit activated — green border + "Active" badge.
  activated,

  /// Benefit unavailable / locked — "Inactive" badge.
  inactive,
}

/// Returns the default heading for a given [DsApBenefitsType].
///
/// Source: `Base • AP Cards / Heading` STRING variable per mode.
String _defaultHeading(DsApBenefitsType type) => switch (type) {
  DsApBenefitsType.shop   => 'Free shopping',
  DsApBenefitsType.meal   => 'Free meals',
  DsApBenefitsType.spa    => 'Free spa',
  DsApBenefitsType.lounge => 'Lounge',
};

/// Returns the default reward chip text for a given [DsApBenefitsType].
///
/// Source: `Base • AP Cards / Benefits` STRING variable per mode.
String _defaultRewardText(DsApBenefitsType type) => switch (type) {
  DsApBenefitsType.shop   => 'Get ₹1,000 back',
  DsApBenefitsType.meal   => 'Get ₹1,000 back',
  DsApBenefitsType.spa    => 'Get ₹1,000 back',
  DsApBenefitsType.lounge => 'Complimentary',
};

/// Card background color per type.
/// Source: `Base • AP Cards / Bg color` COLOR variable, 4 modes.
/// All values are Tier 1 primitives — no Tier 2 alias exists for these themed backgrounds.
// ds-lint-ignore: no_tier1_in_widgets — Base • AP Cards themed backgrounds have no Tier 2 alias.
// These Tier 1 primitives are used intentionally: the designer built a component-specific variable
// collection (Base • AP Cards) with 4 modes, each aliasing a different Tier 1 color. Until Tier 2
// semantic tokens exist for brand/card themes, Tier 1 is the correct level.
Color _cardBg(DsApBenefitsType type) => switch (type) {
  DsApBenefitsType.shop   => ColorPrimitives.secondaryBlue000, // ds-lint-ignore: no_tier1_in_widgets
  DsApBenefitsType.meal   => ColorPrimitives.alertYellow000, // ds-lint-ignore: no_tier1_in_widgets
  DsApBenefitsType.spa    => ColorPrimitives.successGreen000, // ds-lint-ignore: no_tier1_in_widgets
  DsApBenefitsType.lounge => ColorPrimitives.primaryScapia000, // ds-lint-ignore: no_tier1_in_widgets
};

// ds-lint-ignore: no_tier1_in_widgets — Base • AP Cards / Pill bg, same rationale as _cardBg.
Color _pillBg(DsApBenefitsType type) => switch (type) {
  DsApBenefitsType.shop   => ColorPrimitives.secondaryBlue100, // ds-lint-ignore: no_tier1_in_widgets
  DsApBenefitsType.meal   => ColorPrimitives.alertYellow200, // ds-lint-ignore: no_tier1_in_widgets
  DsApBenefitsType.spa    => ColorPrimitives.successGreen200, // ds-lint-ignore: no_tier1_in_widgets
  DsApBenefitsType.lounge => ColorPrimitives.primaryScapia100, // ds-lint-ignore: no_tier1_in_widgets
};

/// AP benefit card — 166×185 dp.
///
/// Two independent variant axes:
/// - [type] — drives color palette (from `Base • AP Cards` Figma variable modes)
/// - [state] — drives border and badge (from `State` Figma VARIANT property)
///
/// Default [heading] and [rewardText] are inferred from [type] when omitted,
/// matching the STRING variable defaults in the Figma `Base • AP Cards` collection.
class DsApBenefits extends StatelessWidget {
  /// Creates a benefit card.
  DsApBenefits({
    super.key,
    required this.type,
    required this.state,
    String? heading,
    String? rewardText,
    this.description = 'Activate with one tap',
    this.onTap,
  })  : heading    = heading    ?? _defaultHeading(type),
        rewardText = rewardText ?? _defaultRewardText(type);

  /// Card color theme. Drives background, chip gradient, and text defaults.
  final DsApBenefitsType type;

  /// Visual state. Drives border and badge visibility.
  final DsApBenefitsState state;

  /// Primary heading. Defaults to the Figma variable default for [type].
  final String heading;

  /// Reward chip text. Defaults to the Figma variable default for [type].
  final String rewardText;

  /// Subtitle below heading (static in Figma design).
  final String description;

  /// Called when the card is tapped. `null` disables tap feedback.
  final VoidCallback? onTap;

  static const double _cardWidth  = 166; // Figma: 166dp FIXED
  static const double _cardHeight = 185; // Figma: 185dp FIXED
  static const double _imageSize  = 66;  // Figma: Image Container 66×66

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
              // Gap: Tier 1 primitive — Base • AP Cards / Bg color, no Tier 2 alias
              color: _cardBg(type), // ds-lint-ignore: no_tier1_in_widgets
              borderRadius: BorderRadius.circular(RadiusTokens.r16),
              // [D] Border: 2dp feedbackPositive only in activated state
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
                  Padding(
                    padding: const EdgeInsets.all(SpacingScale.spaceMdLg), // 13dp ✓
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Illustration placeholder — Gap: export node 550:5857 from Figma
                        const SizedBox(width: _imageSize, height: _imageSize),
                        const SizedBox(height: SpacingScale.spaceMd), // 9dp ✓

                        // Text + chip
                        SizedBox(
                          height: 84, // Figma Container 550:5913 = 84dp
                          child: ClipRect(
                            child: OverflowBox(
                              maxHeight: double.infinity,
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    heading,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TypographyScale.shdSmall.copyWith(
                                      color: colors.contentPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: SpacingScale.space2xs), // 2dp ✓
                                  Text(
                                    description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TypographyScale.pSmall.copyWith(
                                      color: colors.contentSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: SpacingScale.spaceMd), // 9dp ✓
                                  _RewardChip(
                                    text:    rewardText,
                                    pillBg:  _pillBg(type),
                                    cardBg:  _cardBg(type),
                                    colors:  colors,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // [D] Activated badge
                  if (showActiveTag)
                    Positioned(
                      top: 0, right: 0,
                      child: _StateTag(
                        label:     'Active',
                        bgColor:   colors.feedbackPositive,
                        textColor: colors.backgroundPrimary,
                      ),
                    ),

                  // [D] Inactive badge
                  if (showInactiveTag)
                    Positioned(
                      top: 0, right: 0,
                      child: _StateTag(
                        label:     'Inactive',
                        bgColor:   colors.backgroundTertiary,
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

// ─── Reward chip ──────────────────────────────────────────────────────────────

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.text,
    required this.pillBg,
    required this.cardBg,
    required this.colors,
  });

  final String     text;
  final Color      pillBg;  // opaque gradient stop — per type
  final Color      cardBg;  // transparent gradient stop — per type
  final ColorScale colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Gap: LinearGradient — Base • AP Cards / Pill bg per mode → transparent card bg.
        // Tier 1 only; no Tier 2 alias. Raw per user decision.
        gradient: LinearGradient( // ds-lint-ignore: no_hardcoded_color
          begin: Alignment.centerLeft,
          end:   Alignment.centerRight,
          colors: [
            pillBg,
            cardBg.withAlpha(0), // transparent version of card bg
          ],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.spaceSm), // 7dp ✓
        child: Text(
          text,
          style: TypographyScale.pExtraSmall.copyWith(
            color: colors.contentPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── State tag ────────────────────────────────────────────────────────────────

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
          horizontal: SpacingScale.spaceMd,  // 9dp ✓
          vertical:   SpacingScale.space2xs, // 2dp ✓
        ),
        child: Text(
          label,
          style: TypographyScale.pSmall.copyWith(color: textColor),
        ),
      ),
    );
  }
}
