import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ScapiaTheme.light(),
      builder: (context, child) => MediaQuery(
        // Normalise text scale so system fonts don't cause overflow
        // in the fixed-size 166×185 card.
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: child),
      ),
    );

const _base = DsApBenefits(
  heading:    'Free shopping',
  rewardText: 'Get ₹1,000 back',
  state:      DsApBenefitsState.active,
);

void main() {
  group('DsApBenefits — goldens', () {
    testWidgets('active state', (tester) async {
      await tester.pumpWidget(_wrap(const DsApBenefits(
        heading: 'Free shopping', rewardText: 'Get ₹1,000 back', state: DsApBenefitsState.active,
      )));
      await expectLater(find.byType(DsApBenefits), matchesGoldenFile('goldens/ds_ap_benefits_active.png'));
    });

    testWidgets('activated state', (tester) async {
      await tester.pumpWidget(_wrap(const DsApBenefits(
        heading: 'Free shopping', rewardText: 'Get ₹1,000 back', state: DsApBenefitsState.activated,
      )));
      await expectLater(find.byType(DsApBenefits), matchesGoldenFile('goldens/ds_ap_benefits_activated.png'));
    });

    testWidgets('inactive state', (tester) async {
      await tester.pumpWidget(_wrap(const DsApBenefits(
        heading: 'Free shopping', rewardText: 'Get ₹1,000 back', state: DsApBenefitsState.inactive,
      )));
      await expectLater(find.byType(DsApBenefits), matchesGoldenFile('goldens/ds_ap_benefits_inactive.png'));
    });

    testWidgets('edge — long heading', (tester) async {
      await tester.pumpWidget(_wrap(const DsApBenefits(
        heading: 'International lounge access worldwide', rewardText: 'Unlimited visits', state: DsApBenefitsState.active,
      )));
      await expectLater(find.byType(DsApBenefits), matchesGoldenFile('goldens/ds_ap_benefits_long_heading.png'));
    });
  });

  group('DsApBenefits — behaviour', () {
    testWidgets('onTap fires when provided', (tester) async {
      var fired = false;
      await tester.pumpWidget(_wrap(DsApBenefits(
        heading: 'Free shopping', rewardText: 'Get ₹1,000 back',
        state: DsApBenefitsState.active, onTap: () => fired = true,
      )));
      await tester.tap(find.byType(DsApBenefits));
      expect(fired, isTrue);
    });

    testWidgets('onTap suppressed when null', (tester) async {
      await tester.pumpWidget(_wrap(const DsApBenefits(
        heading: 'Free shopping', rewardText: 'Get ₹1,000 back',
        state: DsApBenefitsState.active,
      )));
      await tester.tap(find.byType(DsApBenefits));
    });

    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(_wrap(_base));
      await tester.pump();
      // Verify heading text is present in the widget tree
      expect(find.text('Free shopping'), findsOneWidget);
    });
  });
}
