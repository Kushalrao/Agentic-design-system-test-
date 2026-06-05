import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

// Sample image background to simulate real usage context
const _bgColor = Color(0xFF1A2E44);

Widget _wrap(Widget child) => MaterialApp(
      theme: ScapiaTheme.light(),
      home: Scaffold(
        body: Container(
          color: _bgColor,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

final dsScapiaScoreComponent = WidgetbookComponent(
  name: 'DsScapiaScore',
  useCases: [
    // ── Interactive ──────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        final score = context.knobs.double.slider(
          label: 'Score',
          initialValue: 4.2,
          min: 1.0,
          max: 5.0,
        );
        final showLabel = context.knobs.boolean(
          label: 'Show label',
          initialValue: true,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Excellent',
        );
        final count = context.knobs.string(
          label: 'Count',
          initialValue: '2.4k ratings',
        );

        return _wrap(
          DsScapiaScore(
            score: score,
            label: showLabel ? label : null,
            count: showLabel ? count : null,
          ),
        );
      },
    ),

    // ── With label (default) ─────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'With label — full spec',
      builder: (context) => _wrap(
        const DsScapiaScore(
          score: 4.2,
          label: 'Excellent',
          count: '2.4k ratings',
        ),
      ),
    ),

    // ── Without label ────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Without label — compact',
      builder: (context) => _wrap(
        const DsScapiaScore(score: 4.2),
      ),
    ),

    // ── Edge: no count ───────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — label without count',
      builder: (context) => _wrap(
        const DsScapiaScore(
          score: 3.8,
          label: 'Good',
        ),
      ),
    ),

    // ── Edge: extreme scores ─────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Edge — score 1.0',
      builder: (context) => _wrap(
        const DsScapiaScore(
          score: 1.0,
          label: 'Poor',
          count: '12 ratings',
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Edge — score 5.0',
      builder: (context) => _wrap(
        const DsScapiaScore(
          score: 5.0,
          label: 'Extraordinary',
          count: '10k+ ratings',
        ),
      ),
    ),
  ],
);
