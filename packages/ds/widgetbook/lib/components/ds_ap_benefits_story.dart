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

final dsApBenefitsComponent = WidgetbookComponent(
  name: 'DsApBenefits',
  useCases: [
    // ── Interactive ────────────────────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        final typeIdx = context.knobs.int.slider(
          label: 'Type (0=shop 1=meal 2=spa 3=lounge)',
          initialValue: 0, min: 0, max: 3,
        );
        final stateIdx = context.knobs.int.slider(
          label: 'State (0=active 1=activated 2=inactive)',
          initialValue: 0, min: 0, max: 2,
        );
        return _wrap(DsApBenefits(
          type:  DsApBenefitsType.values[typeIdx],
          state: DsApBenefitsState.values[stateIdx],
          onTap: () {},
        ));
      },
    ),

    // ── All 4 types — default state ────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Shop — active',
      builder: (context) => _wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.active,
      )),
    ),
    WidgetbookUseCase(
      name: 'Meal — active',
      builder: (context) => _wrap(DsApBenefits(
        type: DsApBenefitsType.meal, state: DsApBenefitsState.active,
      )),
    ),
    WidgetbookUseCase(
      name: 'Spa — active',
      builder: (context) => _wrap(DsApBenefits(
        type: DsApBenefitsType.spa, state: DsApBenefitsState.active,
      )),
    ),
    WidgetbookUseCase(
      name: 'Lounge — active',
      builder: (context) => _wrap(DsApBenefits(
        type: DsApBenefitsType.lounge, state: DsApBenefitsState.active,
      )),
    ),

    // ── Activated + Inactive states ────────────────────────────────────────
    WidgetbookUseCase(
      name: 'Shop — activated',
      builder: (context) => _wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.activated,
      )),
    ),
    WidgetbookUseCase(
      name: 'Shop — inactive',
      builder: (context) => _wrap(DsApBenefits(
        type: DsApBenefitsType.shop, state: DsApBenefitsState.inactive,
      )),
    ),
  ],
);
