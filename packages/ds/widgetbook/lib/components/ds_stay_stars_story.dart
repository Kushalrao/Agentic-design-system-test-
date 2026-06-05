import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ScapiaTheme.light(),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: child),
      ),
    );

final dsStayStarsComponent = WidgetbookComponent(
  name: 'DsStayStars',
  useCases: [
    // ── Interactive ──────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        final stars = context.knobs.int.slider(
          label: 'Star count',
          initialValue: 5,
          min: 1,
          max: 5,
        );
        final showLabel = context.knobs.boolean(
          label: 'Show label',
          initialValue: true,
        );
        final labelText = context.knobs.string(
          label: 'Label text',
          initialValue: '5 star hotel',
        );
        return _wrap(
          DsStayStars(
            starCount: stars,
            label: showLabel ? labelText : null,
          ),
        );
      },
    ),

    // ── Full spec — 5 stars with label ───────────────────────────────────────
    WidgetbookUseCase(
      name: 'Default — 5 stars with label',
      builder: (context) => _wrap(
        const DsStayStars(starCount: 5, label: '5 star hotel'),
      ),
    ),

    // ── Stars only (no label) ─────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Stars only — no label',
      builder: (context) => _wrap(
        const DsStayStars(starCount: 5),
      ),
    ),

    // ── Other star counts ─────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: '3 stars',
      builder: (context) => _wrap(
        const DsStayStars(starCount: 3, label: '3 star hotel'),
      ),
    ),
    WidgetbookUseCase(
      name: '1 star',
      builder: (context) => _wrap(
        const DsStayStars(starCount: 1, label: '1 star hotel'),
      ),
    ),
  ],
);
