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
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        final stateIndex = context.knobs.int.slider(
          label: 'State (0=active 1=activated 2=inactive)',
          initialValue: 0,
          min: 0,
          max: 2,
        );
        final state = DsApBenefitsState.values[stateIndex];
        final heading = context.knobs.string(
          label: 'Heading',
          initialValue: 'Free shopping',
        );
        final reward = context.knobs.string(
          label: 'Reward text',
          initialValue: 'Get ₹1,000 back',
        );
        final tappable = context.knobs.boolean(
          label: 'Tappable',
          initialValue: true,
        );
        return _wrap(DsApBenefits(
          heading:    heading,
          rewardText: reward,
          state:      state,
          onTap:      tappable ? () {} : null,
        ));
      },
    ),
    WidgetbookUseCase(
      name: 'Active — default',
      builder: (context) => _wrap(const DsApBenefits(
        heading:    'Free shopping',
        rewardText: 'Get ₹1,000 back',
        state:      DsApBenefitsState.active,
      )),
    ),
    WidgetbookUseCase(
      name: 'Activated — green border + badge',
      builder: (context) => _wrap(const DsApBenefits(
        heading:    'Free shopping',
        rewardText: 'Get ₹1,000 back',
        state:      DsApBenefitsState.activated,
      )),
    ),
    WidgetbookUseCase(
      name: 'Inactive — locked',
      builder: (context) => _wrap(const DsApBenefits(
        heading:    'Free shopping',
        rewardText: 'Get ₹1,000 back',
        state:      DsApBenefitsState.inactive,
      )),
    ),
    WidgetbookUseCase(
      name: 'Edge — long heading',
      builder: (context) => _wrap(const DsApBenefits(
        heading:    'International lounge access worldwide',
        rewardText: 'Unlimited visits',
        state:      DsApBenefitsState.active,
      )),
    ),
    WidgetbookUseCase(
      name: 'Edge — long reward text',
      builder: (context) => _wrap(const DsApBenefits(
        heading:    'Cashback',
        rewardText: 'Get up to ₹10,000 back per month',
        state:      DsApBenefitsState.activated,
      )),
    ),
  ],
);
