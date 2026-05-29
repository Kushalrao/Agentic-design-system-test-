import 'package:flutter/material.dart';
import 'package:scapia_tokens/scapia_tokens.dart';

abstract final class ScapiaTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorScale.light.brandPrimary,
          brightness: Brightness.light,
        ),
        fontFamily: Foundation.fontFamilyLexendDeca,
        extensions: [ColorScale.light],
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorScale.light.brandPrimary,
          brightness: Brightness.dark,
        ),
        fontFamily: Foundation.fontFamilyLexendDeca,
        extensions: [ColorScale.light],
      );
}
