import 'package:flutter/material.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

/// The visual style of a [DsButton].
enum DsButtonVariant {
  /// Filled brand orange — primary CTA, one per screen.
  primary,

  /// Filled dark navy — alternate primary CTA.
  dark,

  /// Outlined brand border, transparent fill — secondary actions.
  secondary,

  /// Text-only, no border — low-emphasis / tertiary actions.
  ghost,
}

/// A tappable call-to-action button.
///
/// Pass `onPressed: null` to render the disabled state. Set [isLoading] to
/// block interaction and show a spinner while an async operation runs.
///
/// Typography: [TypographyScale.hdMedium] — 19 / SemiBold / lh 27.
class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
  });

  /// Button label text.
  final String label;

  /// Tap handler. Pass `null` to show the disabled state.
  final VoidCallback? onPressed;

  /// Visual style of the button. Defaults to [DsButtonVariant.primary].
  final DsButtonVariant variant;

  /// Shows a loading spinner in place of the label and blocks interaction.
  final bool isLoading;

  /// Optional icon placed before the label.
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorScale>()!;
    final isDisabled = onPressed == null || isLoading;

    final Color bgColor;
    final Color fgColor;
    final Border? border;

    switch (variant) {
      case DsButtonVariant.primary:
        bgColor = isDisabled ? colors.backgroundTertiary : colors.brandPrimary;
        fgColor = isDisabled ? colors.contentTertiary    : colors.backgroundPrimary;
        border  = null;
      case DsButtonVariant.dark:
        bgColor = isDisabled ? colors.backgroundTertiary : colors.brandDark;
        fgColor = isDisabled ? colors.contentTertiary    : colors.backgroundPrimary;
        border  = null;
      case DsButtonVariant.secondary:
        bgColor = colors.backgroundPrimary;
        fgColor = isDisabled ? colors.contentTertiary : colors.brandPrimary;
        border  = Border.all(
          color: isDisabled ? colors.borderOpaque : colors.brandPrimary,
          width: 2,
        );
      case DsButtonVariant.ghost:
        bgColor = const Color(0x00000000);
        fgColor = isDisabled ? colors.contentTertiary : colors.brandPrimary;
        border  = null;
    }

    // Hd-Medium: 19 / SemiBold / lh 27 — the canonical style for button labels.
    final textStyle = TypographyScale.hdMedium.copyWith(color: fgColor);

    return Semantics(
      button: true,
      label:   label,
      enabled: !isDisabled,
      child: Material(
        color: const Color(0x00000000),
        child: InkWell(
          onTap:        isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(RadiusTokens.full),
          child: Ink(
            decoration: BoxDecoration(
              color:        bgColor,
              borderRadius: BorderRadius.circular(RadiusTokens.full),
              border:       border,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingScale.space3xl,  // 29 dp
                vertical:   SpacingScale.spaceLg,   // 15 dp
              ),
              child: Row(
                mainAxisSize:       MainAxisSize.min,
                mainAxisAlignment:  MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingIcon != null && !isLoading) ...[
                    Icon(leadingIcon, color: fgColor, size: TypographyScale.hdMediumSize),
                    const SizedBox(width: SpacingScale.spaceMd),
                  ],
                  if (isLoading)
                    SizedBox(
                      width:  TypographyScale.hdMediumSize,
                      height: TypographyScale.hdMediumSize,
                      child:  CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:  AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  else
                    Text(label, style: textStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
