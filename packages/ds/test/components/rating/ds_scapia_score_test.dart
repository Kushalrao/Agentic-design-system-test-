import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

// Dark background to simulate real usage (rating pill always sits over images)
Widget _wrap(Widget child) => MaterialApp(
      theme: ScapiaTheme.light(),
      home: Scaffold(
        backgroundColor: const Color(0xFF1A2E44),
        body: Center(child: child),
      ),
    );

void main() {
  group('DsScapiaScore — goldens', () {
    // ── State=With label ────────────────────────────────────────────────────
    testWidgets('with label — full spec', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsScapiaScore(
          score: 4.2,
          label: 'Excellent',
          count: '2.4k ratings',
        ),
      ));
      await expectLater(
        find.byType(DsScapiaScore),
        matchesGoldenFile('goldens/ds_scapia_score_with_label.png'),
      );
    });

    // ── State=without label ─────────────────────────────────────────────────
    testWidgets('without label — compact', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsScapiaScore(score: 4.2),
      ));
      await expectLater(
        find.byType(DsScapiaScore),
        matchesGoldenFile('goldens/ds_scapia_score_without_label.png'),
      );
    });

    // ── Edge: label with no count ───────────────────────────────────────────
    testWidgets('label without count', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsScapiaScore(score: 3.8, label: 'Good'),
      ));
      await expectLater(
        find.byType(DsScapiaScore),
        matchesGoldenFile('goldens/ds_scapia_score_no_count.png'),
      );
    });

    // ── Edge: score 1.0 ─────────────────────────────────────────────────────
    testWidgets('score 1.0', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsScapiaScore(score: 1.0, label: 'Poor', count: '12 ratings'),
      ));
      await expectLater(
        find.byType(DsScapiaScore),
        matchesGoldenFile('goldens/ds_scapia_score_1_0.png'),
      );
    });

    // ── Edge: score 5.0 + long strings ──────────────────────────────────────
    testWidgets('score 5.0', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsScapiaScore(
          score: 5.0,
          label: 'Extraordinary',
          count: '10k+ ratings',
        ),
      ));
      await expectLater(
        find.byType(DsScapiaScore),
        matchesGoldenFile('goldens/ds_scapia_score_5_0.png'),
      );
    });

    // ── Semantics ────────────────────────────────────────────────────────────
    testWidgets('has accessibility label with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsScapiaScore(score: 4.2, label: 'Excellent', count: '2.4k ratings'),
      ));
      final semantics = tester.getSemantics(find.byType(DsScapiaScore));
      expect(semantics.label, contains('Rating: 4.2 — Excellent, 2.4k ratings'));
    });

    testWidgets('has accessibility label compact', (tester) async {
      await tester.pumpWidget(_wrap(
        const DsScapiaScore(score: 4.2),
      ));
      final semantics = tester.getSemantics(find.byType(DsScapiaScore));
      expect(semantics.label, contains('Rating: 4.2'));
    });
  });
}
