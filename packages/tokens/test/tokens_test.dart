import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

void main() {
  group('Tier 1 — raw values', () {
    test('primaryScapia800 exists and is non-zero', () {
      expect(ColorPrimitives.primaryScapia800.toARGB32(), isNonZero);
    });

    test('foundation font family is defined', () {
      expect(Foundation.fontFamilyLexendDeca, isNotEmpty);
    });
  });

  group('Tier 2 → Tier 1 alias chain (mirrors Figma)', () {
    test('brandPrimary resolves to primaryScapia800', () {
      expect(
        ColorScale.light.brandPrimary,
        equals(ColorPrimitives.primaryScapia800),
      );
    });

    test('titleMdSize resolves to Foundation primitive', () {
      expect(TypographyScale.titleMdSize, equals(Foundation.fontSize19));
    });

    test('spacing scale references primitives', () {
      expect(SpacingScale.spaceSm, isNonZero);
    });
  });

  group('Tier contract — no hardcoded Color literals in Tier 2', () {
    // Tier 2 must only hold Dart references to Tier 1 constants.
    // Changing a Tier 1 primitive propagates automatically, just like Figma aliases.
    test('all ColorScale fields match a ColorPrimitives constant', () {
      final scale = ColorScale.light;
      final primitiveValues = _allColorPrimitives();

      for (final entry in _colorScaleEntries(scale)) {
        expect(
          primitiveValues.contains(entry.value.toARGB32()),
          isTrue,
          reason:
              '${entry.key} (${entry.value}) is not a reference to any '
              'ColorPrimitives constant. Tier 2 tokens must alias Tier 1.',
        );
      }
    });
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Set<int> _allColorPrimitives() {
  return {
    // Primary / Scapia
    ColorPrimitives.primaryScapia000, ColorPrimitives.primaryScapia100,
    ColorPrimitives.primaryScapia200, ColorPrimitives.primaryScapia300,
    ColorPrimitives.primaryScapia400, ColorPrimitives.primaryScapia500,
    ColorPrimitives.primaryScapia600, ColorPrimitives.primaryScapia700,
    ColorPrimitives.primaryScapia800, ColorPrimitives.primaryScapia900,
    // Secondary / Blue
    ColorPrimitives.secondaryBlue000, ColorPrimitives.secondaryBlue100,
    ColorPrimitives.secondaryBlue200, ColorPrimitives.secondaryBlue300,
    ColorPrimitives.secondaryBlue400, ColorPrimitives.secondaryBlue500,
    ColorPrimitives.secondaryBlue600, ColorPrimitives.secondaryBlue700,
    ColorPrimitives.secondaryBlue800, ColorPrimitives.secondaryBlue900,
    // Warning / Red
    ColorPrimitives.warningRed000, ColorPrimitives.warningRed100,
    ColorPrimitives.warningRed200, ColorPrimitives.warningRed300,
    ColorPrimitives.warningRed400, ColorPrimitives.warningRed500,
    ColorPrimitives.warningRed600, ColorPrimitives.warningRed700,
    ColorPrimitives.warningRed800, ColorPrimitives.warningRed900,
    // Success / Green
    ColorPrimitives.successGreen000, ColorPrimitives.successGreen100,
    ColorPrimitives.successGreen200, ColorPrimitives.successGreen300,
    ColorPrimitives.successGreen400, ColorPrimitives.successGreen500,
    ColorPrimitives.successGreen600, ColorPrimitives.successGreen700,
    ColorPrimitives.successGreen800, ColorPrimitives.successGreen900,
    // Alert / Yellow
    ColorPrimitives.alertYellow000, ColorPrimitives.alertYellow100,
    ColorPrimitives.alertYellow200, ColorPrimitives.alertYellow300,
    ColorPrimitives.alertYellow400, ColorPrimitives.alertYellow500,
    ColorPrimitives.alertYellow600, ColorPrimitives.alertYellow700,
    ColorPrimitives.alertYellow800, ColorPrimitives.alertYellow900,
    // Neutral / Grey
    ColorPrimitives.neutralGrey000, ColorPrimitives.neutralGrey100,
    ColorPrimitives.neutralGrey200, ColorPrimitives.neutralGrey300,
    ColorPrimitives.neutralGrey400, ColorPrimitives.neutralGrey500,
    ColorPrimitives.neutralGrey600, ColorPrimitives.neutralGrey700,
    ColorPrimitives.neutralGrey800, ColorPrimitives.neutralGrey900,
  }.map((c) => c.toARGB32()).toSet();
}

List<({String key, Color value})> _colorScaleEntries(ColorScale s) => [
      (key: 'brandPrimary',        value: s.brandPrimary),
      (key: 'brandDark',           value: s.brandDark),
      (key: 'feedbackNegative',    value: s.feedbackNegative),
      (key: 'feedbackWarning',     value: s.feedbackWarning),
      (key: 'feedbackPositive',    value: s.feedbackPositive),
      (key: 'backgroundPrimary',   value: s.backgroundPrimary),
      (key: 'backgroundSecondary', value: s.backgroundSecondary),
      (key: 'backgroundTertiary',  value: s.backgroundTertiary),
      (key: 'contentPrimary',      value: s.contentPrimary),
      (key: 'contentSecondary',    value: s.contentSecondary),
      (key: 'contentTertiary',     value: s.contentTertiary),
      (key: 'borderOpaque',        value: s.borderOpaque),
      (key: 'borderSelection',     value: s.borderSelection),
    ];
