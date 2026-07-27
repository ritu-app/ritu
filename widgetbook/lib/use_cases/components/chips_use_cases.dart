import 'package:flutter/material.dart';
import 'package:ritu/features/setup/widgets/choice_chips.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Interactive',
  type: RituChoiceChip,
  path: '[Components]/Chips',
)
Widget rituChoiceChipInteractiveUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'Label', initialValue: 'Light');
  final selected = context.knobs.boolean(
    label: 'Selected',
    initialValue: false,
  );

  return Center(
    child: RituChoiceChip(label: label, selected: selected, onTap: () {}),
  );
}

/// Regression check for the bug where chips inside a [Wrap] stacked
/// vertically instead of flowing left-to-right (see `RituChoiceChip`'s
/// conditional `alignment` fix).
@widgetbook.UseCase(
  name: 'Wrap of options',
  type: RituChoiceChip,
  path: '[Components]/Chips',
)
Widget rituChoiceChipWrapUseCase(BuildContext context) {
  const options = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];
  final selected = context.knobs.object.dropdown<String>(
    label: 'Selected option',
    options: options,
    initialOption: 'Light',
  );

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          RituChoiceChip(
            label: option,
            selected: option == selected,
            onTap: () {},
          ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: RituDateChip, path: '[Components]')
Widget rituDateChipUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Jun 12, 2026',
  );

  return Center(
    child: RituDateChip(label: label, onRemove: () {}),
  );
}

@widgetbook.UseCase(
  name: 'List of dates',
  type: RituDateChip,
  path: '[Components]',
)
Widget rituDateChipListUseCase(BuildContext context) {
  return _DateChipListPreview();
}

class _DateChipListPreview extends StatefulWidget {
  @override
  State<_DateChipListPreview> createState() => _DateChipListPreviewState();
}

class _DateChipListPreviewState extends State<_DateChipListPreview> {
  var _dates = const ['Jun 12, 2026', 'May 30, 2026', 'May 2, 2026'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final date in _dates)
            RituDateChip(
              label: date,
              onRemove: () => setState(
                () => _dates = _dates.where((d) => d != date).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
