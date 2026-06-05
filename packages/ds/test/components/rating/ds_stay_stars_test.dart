import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ScapiaTheme.light(),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: child),
      ),
    );

void main() {
  group('DsStayStars — goldens', () {
    testWidgets('5 stars with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsStayStars(starCount: 5, label: '5 star hotel'),
      ));
      await expectLater(
        find.byType(DsStayStars),
        matchesGoldenFile('goldens/ds_stay_stars_5_with_label.png'),
      );
    });

    testWidgets('5 stars no label', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsStayStars(starCount: 5),
      ));
      await expectLater(
        find.byType(DsStayStars),
        matchesGoldenFile('goldens/ds_stay_stars_5_no_label.png'),
      );
    });

    testWidgets('3 stars with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsStayStars(starCount: 3, label: '3 star hotel'),
      ));
      await expectLater(
        find.byType(DsStayStars),
        matchesGoldenFile('goldens/ds_stay_stars_3.png'),
      );
    });

    testWidgets('1 star with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsStayStars(starCount: 1, label: '1 star hotel'),
      ));
      await expectLater(
        find.byType(DsStayStars),
        matchesGoldenFile('goldens/ds_stay_stars_1.png'),
      );
    });

    testWidgets('semantics with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsStayStars(starCount: 5, label: '5 star hotel'),
      ));
      final semantics = tester.getSemantics(find.byType(DsStayStars));
      expect(semantics.label, contains('5 star hotel'));
    });

    testWidgets('semantics without label', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsStayStars(starCount: 3),
      ));
      final semantics = tester.getSemantics(find.byType(DsStayStars));
      expect(semantics.label, contains('3 star'));
    });
  });
}
