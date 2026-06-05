// GENERATED — source of truth: Figma › Seasonal DLS › Color Semantics collection.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'color_primitives.dart';

/// Tier 2 — semantic color aliases. Each field is a Dart reference to a
/// [ColorPrimitives] constant, mirroring the Figma alias chain exactly.
///
/// Use as a [ThemeExtension] so dark / seasonal modes can be swapped at runtime:
/// ```dart
/// Theme.of(context).extension<ColorScale>()!.brandPrimary
/// ```
@immutable
class ColorScale extends ThemeExtension<ColorScale> {
  const ColorScale({
    // Brand
    required this.brandPrimary,
    required this.brandDark,
    // Feedback
    required this.feedbackNegative,
    required this.feedbackWarning,
    required this.feedbackPositive,
    // Surface › Background
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    // Surface › Content (text / icon)
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentTertiary,
    // Surface › Border
    required this.borderOpaque,
    required this.borderSelection,
  });

  // ── Brand ────────────────────────────────────────────────────────────────
  /// Primary brand orange — CTAs, active states, brand moments.
  final Color brandPrimary;

  /// Dark navy — alternate primary button, high-contrast surfaces.
  final Color brandDark;

  // ── Feedback ─────────────────────────────────────────────────────────────
  /// Destructive / error state.
  final Color feedbackNegative;

  /// Caution / in-progress state.
  final Color feedbackWarning;

  /// Success / confirmation state.
  final Color feedbackPositive;

  // ── Surface › Background ─────────────────────────────────────────────────
  /// Page-level background — white.
  final Color backgroundPrimary;

  /// Card / section background — light grey-blue.
  final Color backgroundSecondary;

  /// Subtle divider / wash background.
  final Color backgroundTertiary;

  // ── Surface › Content ────────────────────────────────────────────────────
  /// Primary body text and icons.
  final Color contentPrimary;

  /// Secondary / supporting text.
  final Color contentSecondary;

  /// Disabled / placeholder text.
  final Color contentTertiary;

  // ── Surface › Border ─────────────────────────────────────────────────────
  /// Default visible border.
  final Color borderOpaque;

  /// Selected / focus border — high contrast.
  final Color borderSelection;

  // ── Light mode (mirrors Figma Color Semantics → Colors alias chain) ───────
  static const light = ColorScale(
    // Brand/Primary → Primary/Scapia/800
    brandPrimary:        ColorPrimitives.primaryScapia800,
    // Brand/Dark → Secondary/Blue/900
    brandDark:           ColorPrimitives.secondaryBlue900,
    // Feedback/Negative → Warning/Red/400
    feedbackNegative:    ColorPrimitives.warningRed400,
    // Feedback/Warning → Alert/Yellow/400
    feedbackWarning:     ColorPrimitives.alertYellow400,
    // Feedback/Positive → Success/Green/400
    feedbackPositive:    ColorPrimitives.successGreen400,
    // Surface/Background/Primary → Neutral/Grey/000
    backgroundPrimary:   ColorPrimitives.neutralGrey000,
    // Surface/Background/Secondary → Neutral/Grey/100
    backgroundSecondary: ColorPrimitives.neutralGrey100,
    // Surface/Background/Tertiary → Neutral/Grey/200
    backgroundTertiary:  ColorPrimitives.neutralGrey200,
    // Surface/Content/Primary → Neutral/Grey/900
    contentPrimary:      ColorPrimitives.neutralGrey900,
    // Surface/Content/Secondary → Neutral/Grey/600
    contentSecondary:    ColorPrimitives.neutralGrey600,
    // Surface/Content/Tertiary → Neutral/Grey/500
    contentTertiary:     ColorPrimitives.neutralGrey500,
    // Surface/Border/Opaque → Neutral/Grey/200
    borderOpaque:        ColorPrimitives.neutralGrey200,
    // Surface/Border/Selection → Neutral/Grey/900
    borderSelection:     ColorPrimitives.neutralGrey900,
  );

  @override
  ColorScale copyWith({
    Color? brandPrimary,
    Color? brandDark,
    Color? feedbackNegative,
    Color? feedbackWarning,
    Color? feedbackPositive,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentTertiary,
    Color? borderOpaque,
    Color? borderSelection,
  }) =>
      ColorScale(
        brandPrimary:        brandPrimary        ?? this.brandPrimary,
        brandDark:           brandDark           ?? this.brandDark,
        feedbackNegative:    feedbackNegative    ?? this.feedbackNegative,
        feedbackWarning:     feedbackWarning     ?? this.feedbackWarning,
        feedbackPositive:    feedbackPositive    ?? this.feedbackPositive,
        backgroundPrimary:   backgroundPrimary   ?? this.backgroundPrimary,
        backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
        backgroundTertiary:  backgroundTertiary  ?? this.backgroundTertiary,
        contentPrimary:      contentPrimary      ?? this.contentPrimary,
        contentSecondary:    contentSecondary    ?? this.contentSecondary,
        contentTertiary:     contentTertiary     ?? this.contentTertiary,
        borderOpaque:        borderOpaque        ?? this.borderOpaque,
        borderSelection:     borderSelection     ?? this.borderSelection,
      );

  @override
  ColorScale lerp(ThemeExtension<ColorScale>? other, double t) {
    if (other is! ColorScale) return this;
    return ColorScale(
      brandPrimary:        Color.lerp(brandPrimary,        other.brandPrimary,        t)!,
      brandDark:           Color.lerp(brandDark,           other.brandDark,           t)!,
      feedbackNegative:    Color.lerp(feedbackNegative,    other.feedbackNegative,    t)!,
      feedbackWarning:     Color.lerp(feedbackWarning,     other.feedbackWarning,     t)!,
      feedbackPositive:    Color.lerp(feedbackPositive,    other.feedbackPositive,    t)!,
      backgroundPrimary:   Color.lerp(backgroundPrimary,   other.backgroundPrimary,   t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundTertiary:  Color.lerp(backgroundTertiary,  other.backgroundTertiary,  t)!,
      contentPrimary:      Color.lerp(contentPrimary,      other.contentPrimary,      t)!,
      contentSecondary:    Color.lerp(contentSecondary,    other.contentSecondary,    t)!,
      contentTertiary:     Color.lerp(contentTertiary,     other.contentTertiary,     t)!,
      borderOpaque:        Color.lerp(borderOpaque,        other.borderOpaque,        t)!,
      borderSelection:     Color.lerp(borderSelection,     other.borderSelection,     t)!,
    );
  }
}
