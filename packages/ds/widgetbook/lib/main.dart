import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

import 'components/button_story.dart';
import 'components/ds_scapia_score_story.dart';
import 'components/ds_stay_stars_story.dart';
import 'components/stays_property_card_story.dart';
import 'components/stays_srp_story.dart';

void main() => runApp(const WidgetbookShell());

class WidgetbookShell extends StatelessWidget {
  const WidgetbookShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      directories: [
        WidgetbookFolder(
          name: 'Components',
          children: [buttonComponent],
        ),
        WidgetbookFolder(
          name: 'Rating',
          children: [dsScapiaScoreComponent, dsStayStarsComponent],
        ),
        WidgetbookFolder(
          name: 'Stays',
          children: [staysSrpComponent, staysPropertyCardComponent],
        ),
      ],
      addons: [
        ThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: ScapiaTheme.light()),
          ],
          themeBuilder: (context, theme, child) =>
              Theme(data: theme, child: child),
        ),
        TextScaleAddon(initialScale: 1.0),
      ],
      appBuilder: (context, child) => MaterialApp(
        theme: ScapiaTheme.light(),
        debugShowCheckedModeBanner: false,
        home: child,
      ),
    );
  }
}
