import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';
import 'package:widgetbook/widgetbook.dart';

final buttonComponent = WidgetbookComponent(
  name: 'DsButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Book flights',
        );
        final variant = context.knobs.object.dropdown(
          label: 'Variant',
          options: DsButtonVariant.values,
          initialOption: DsButtonVariant.primary,
          labelBuilder: (v) => v.name,
        );
        final isLoading = context.knobs.boolean(
          label: 'Loading',
        );
        final isDisabled = context.knobs.boolean(
          label: 'Disabled',
        );
        final showIcon = context.knobs.boolean(
          label: 'Leading icon',
        );
        return DsButton(
          label: label,
          onPressed: isDisabled ? null : () {},
          variant: variant,
          isLoading: isLoading,
          leadingIcon: showIcon ? Icons.flight_takeoff : null,
        );
      },
    ),
    WidgetbookUseCase(
      name: 'All variants',
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final variant in DsButtonVariant.values) ...[
            DsButton(
              label: variant.name,
              onPressed: () {},
              variant: variant,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
    WidgetbookUseCase(
      name: 'All states — primary',
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DsButton(label: 'Default', onPressed: () {}),
          const SizedBox(height: 12),
          const DsButton(label: 'Disabled', onPressed: null),
          const SizedBox(height: 12),
          DsButton(label: 'Loading', onPressed: () {}, isLoading: true),
          const SizedBox(height: 12),
          DsButton(
            label: 'With icon',
            onPressed: () {},
            leadingIcon: Icons.arrow_forward,
          ),
        ],
      ),
    ),
  ],
);
