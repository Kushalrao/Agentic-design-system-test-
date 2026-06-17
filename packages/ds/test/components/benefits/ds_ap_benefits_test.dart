import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ScapiaTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: child),
      ),
    );

void main() {
  group('DsApBenefits — goldens (type × state)', () {
    // 4 types × active state
    for (final type in DsApBenefitsType.values) {
      testWidgets('${type.name} / active', (tester) async {
        await tester.pumpWidget(_wrap(DsApBenefits(
          type: type, state: DsApBenefitsState.active,
        )));
        await expectLater(
          find.byType(DsApBenefits),
          matchesGoldenFile('goldens/ds_ap_benefits_${type.name}_active.png'),
        );
      });
    }

    // Activated and inactive for shop (representative — border/badge logic)
    testWidgets('shop / activated', (tester) async {
      await tester.pumpWidget(_wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.activated,
      )));
      await expectLater(
        find.byType(DsApBenefits),
        matchesGoldenFile('goldens/ds_ap_benefits_shop_activated.png'),
      );
    });

    testWidgets('shop / inactive', (tester) async {
      await tester.pumpWidget(_wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.inactive,
      )));
      await expectLater(
        find.byType(DsApBenefits),
        matchesGoldenFile('goldens/ds_ap_benefits_shop_inactive.png'),
      );
    });
  });

  group('DsApBenefits — defaults', () {
    test('shop defaults heading to Free shopping', () {
      final card = DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.active,
      );
      expect(card.heading, 'Free shopping');
      expect(card.rewardText, 'Get ₹1,000 back');
    });

    test('lounge defaults heading to Lounge and reward to Complimentary', () {
      final card = DsApBenefits(
        type: DsApBenefitsType.lounge, state: DsApBenefitsState.active,
      );
      expect(card.heading, 'Lounge');
      expect(card.rewardText, 'Complimentary');
    });

    test('custom heading overrides default', () {
      final card = DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.active,
        heading: 'Custom title',
      );
      expect(card.heading, 'Custom title');
    });
  });

  group('DsApBenefits — behaviour', () {
    testWidgets('onTap fires when provided', (tester) async {
      var fired = false;
      await tester.pumpWidget(_wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.active,
        onTap: () => fired = true,
      )));
      await tester.tap(find.byType(DsApBenefits));
      expect(fired, isTrue);
    });

    testWidgets('onTap suppressed when null', (tester) async {
      await tester.pumpWidget(_wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.active,
      )));
      await tester.tap(find.byType(DsApBenefits));
    });

    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(_wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.active,
      )));
      await tester.pump();
      expect(find.text('Free shopping'), findsOneWidget);
    });
  });
}
