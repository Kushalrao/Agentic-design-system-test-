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
  group('DsButton — goldens', () {
    for (final variant in DsButtonVariant.values) {
      testWidgets('${variant.name} default', (tester) async {
        await tester.pumpWidget(_wrap(
          DsButton(label: 'Button', onPressed: () {}, variant: variant),
        ));
        await expectLater(
          find.byType(DsButton),
          matchesGoldenFile('goldens/button_${variant.name}_default.png'),
        );
      });

      testWidgets('${variant.name} disabled', (tester) async {
        await tester.pumpWidget(_wrap(
          DsButton(label: 'Button', onPressed: null, variant: variant),
        ));
        await expectLater(
          find.byType(DsButton),
          matchesGoldenFile('goldens/button_${variant.name}_disabled.png'),
        );
      });

      testWidgets('${variant.name} loading', (tester) async {
        await tester.pumpWidget(_wrap(
          DsButton(
            label: 'Button',
            onPressed: () {},
            variant: variant,
            isLoading: true,
          ),
        ));
        await expectLater(
          find.byType(DsButton),
          matchesGoldenFile('goldens/button_${variant.name}_loading.png'),
        );
      });
    }

    testWidgets('primary with leading icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsButton(
          label: 'Continue',
          onPressed: null,
          leadingIcon: Icons.arrow_forward,
        ),
      ));
      await expectLater(
        find.byType(DsButton),
        matchesGoldenFile('goldens/button_primary_with_icon.png'),
      );
    });
  });

  group('DsButton — behaviour', () {
    testWidgets('fires onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        DsButton(label: 'Go', onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(DsButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not fire when onPressed is null', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        DsButton(label: 'Go', onPressed: null),
      ));
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('does not fire when isLoading is true', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        DsButton(label: 'Go', onPressed: () => tapped = true, isLoading: true),
      ));
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('shows label text when not loading', (tester) async {
      await tester.pumpWidget(_wrap(
        DsButton(label: 'Pay now', onPressed: () {}),
      ));
      expect(find.text('Pay now'), findsOneWidget);
    });

    testWidgets('hides label and shows spinner when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        DsButton(label: 'Pay now', onPressed: () {}, isLoading: true),
      ));
      expect(find.text('Pay now'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hit target is at least 44dp tall', (tester) async {
      await tester.pumpWidget(_wrap(
        DsButton(label: 'Go', onPressed: () {}),
      ));
      final size = tester.getSize(find.byType(DsButton));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('has Semantics button role', (tester) async {
      await tester.pumpWidget(_wrap(
        DsButton(label: 'Book now', onPressed: () {}),
      ));
      final semantics = tester.getSemantics(find.byType(DsButton));
      expect(semantics.flagsCollection.isButton, isTrue);
    });
  });
}
