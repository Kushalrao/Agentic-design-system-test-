import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

import 'components/button_story.dart';
import 'components/stays_property_card_story.dart';
import 'components/stays_srp_story.dart';

void main() => runApp(const WidgetbookShell());

class WidgetbookShell extends StatelessWidget {
  const WidgetbookShell({super.key});

  // google_fonts registers Lexend Deca as 'LexendDeca' (camelCase, no space).
  // ScapiaTheme.light() sets fontFamily: 'Lexend Deca' (spaced) — Flutter can't
  // match them and falls back to the system font.
  // ThemeData.copyWith() has no fontFamily parameter in Flutter 3.x, so we
  // rebuild the theme directly using the exact name google_fonts registered.
  static ThemeData get _theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor:  ColorScale.light.brandPrimary,
      brightness: Brightness.light,
    ),
    fontFamily: GoogleFonts.lexendDeca().fontFamily,
    extensions: const [ColorScale.light],
    textTheme:  GoogleFonts.lexendDecaTextTheme(),
  );

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      directories: [
        WidgetbookFolder(
          name: 'Components',
          children: [buttonComponent],
        ),
        WidgetbookFolder(
          name: 'Stays',
          children: [staysSrpComponent, staysPropertyCardComponent],
        ),
      ],
      addons: [
        ThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: _theme),
          ],
          themeBuilder: (context, theme, child) =>
              Theme(data: theme, child: child),
        ),
        TextScaleAddon(initialScale: 1.0),
      ],
      appBuilder: (context, child) => MaterialApp(
        theme: _theme,
        debugShowCheckedModeBanner: false,
        home: child,
      ),
    );
  }
}
