import 'package:flutter/material.dart';
import 'package:ritu/features/setup/widgets/setup_footer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: SetupFooter,
  path: '[Components]/Buttons',
)
Widget setupFooterUseCase(BuildContext context) {
  final primaryLabel = context.knobs.string(
    label: 'Primary label',
    initialValue: 'Continue',
  );
  final secondaryLabel = context.knobs.string(
    label: 'Secondary label',
    initialValue: 'Skip for now',
  );
  final primaryEnabled = context.knobs.boolean(
    label: 'Primary enabled',
    initialValue: true,
  );

  return Padding(
    padding: const EdgeInsets.all(16),
    child: SetupFooter(
      primaryLabel: primaryLabel,
      primaryEnabled: primaryEnabled,
      onPrimary: () {},
      secondaryLabel: secondaryLabel,
      onSecondary: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Default',
  type: OutlinedPillButton,
  path: '[Components]/Buttons',
)
Widget outlinedPillButtonUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Add body signal',
  );
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: OutlinedPillButton(label: label, onPressed: enabled ? () {} : null),
  );
}
