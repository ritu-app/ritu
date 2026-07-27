import 'package:flutter/material.dart';
import 'package:ritu/features/setup/widgets/progress_dots.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ProgressDots, path: '[Components]')
Widget progressDotsUseCase(BuildContext context) {
  final totalSteps = context.knobs.int.slider(
    label: 'Total steps',
    initialValue: 4,
    min: 2,
    max: 6,
  );
  final currentStep = context.knobs.int.slider(
    label: 'Current step',
    initialValue: 1,
    min: 1,
    max: 6,
  );

  return Center(
    child: ProgressDots(
      currentStep: currentStep.clamp(1, totalSteps),
      totalSteps: totalSteps,
    ),
  );
}
