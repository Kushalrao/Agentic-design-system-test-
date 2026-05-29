// source of truth: Figma › Seasonal DLS › Button collection (Tier 3).
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'color_scale.dart';

/// Tier 3 — component tokens for [DsButton].
/// Each getter aliases a [ColorScale] semantic token, mirroring the
/// Button collection in Figma (Button → Color Semantics → Colors → value).
abstract final class ButtonTokens {
  // ── Primary Orange ────────────────────────────────────────────────────────
  /// Button/Primary/Orange/Background → Brand/Primary → Primary/Scapia/800
  static Color primaryOrangeBackground(BuildContext context) =>
      Theme.of(context).extension<ColorScale>()!.brandPrimary;

  /// Button/Primary/Orange/Label → Surface/Background/Primary → Neutral/Grey/000
  static Color primaryOrangeLabel(BuildContext context) =>
      Theme.of(context).extension<ColorScale>()!.backgroundPrimary;

  // ── Primary Black ─────────────────────────────────────────────────────────
  /// Button/Primary/Black/Background → Brand/Dark → Secondary/Blue/900
  static Color primaryBlackBackground(BuildContext context) =>
      Theme.of(context).extension<ColorScale>()!.brandDark;

  /// Button/Primary/Black/Label → Surface/Background/Primary → Neutral/Grey/000
  static Color primaryBlackLabel(BuildContext context) =>
      Theme.of(context).extension<ColorScale>()!.backgroundPrimary;
}
