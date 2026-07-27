import 'package:flutter/material.dart';
import 'package:ritu/features/log/widgets/log_slider_card.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: LogSliderCard, path: '[Components]')
Widget logSliderCardUseCase(BuildContext context) {
  return const _LogSliderCardPreview();
}

class _LogSliderCardPreview extends StatefulWidget {
  const _LogSliderCardPreview();

  @override
  State<_LogSliderCardPreview> createState() => _LogSliderCardPreviewState();
}

class _LogSliderCardPreviewState extends State<_LogSliderCardPreview> {
  var _value = 4;

  @override
  Widget build(BuildContext context) {
    final title = context.knobs.string(
      label: 'Title',
      initialValue: 'Cramp intensity',
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LogSliderCard(
        title: title,
        value: _value,
        labels: const ['None', 'Moderate', 'Intense'],
        onChanged: (v) => setState(() => _value = v),
      ),
    );
  }
}
