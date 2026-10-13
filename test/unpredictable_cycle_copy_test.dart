import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle_classification.dart';
import 'package:ritu/features/insights/unpredictable_cycle_copy.dart';

void main() {
  test('describes the shortest and longest lengths in the sample', () {
    final copy = unpredictableCycleCopy(
      classification: CycleClassification.unpredictable,
      cycleLengths: const [21, 46, 24],
    );

    expect(
      copy?.howInsightsBody,
      'Your cycles vary quite a bit (21–46 days). '
      "Phase strips aren't shown. Patterns here are based on what "
      "you've logged, not cycle timing.",
    );
    expect(copy?.title, 'Cycles vary significantly - 21 to 46 days');
    expect(copy?.recorded, '3 cycles recorded');
  });

  test('stays hidden until the cycle is unpredictable', () {
    expect(
      unpredictableCycleCopy(
        classification: CycleClassification.variable,
        cycleLengths: const [21, 46, 24],
      ),
      isNull,
    );
    expect(
      unpredictableCycleCopy(
        classification: CycleClassification.unpredictable,
        cycleLengths: const [],
      ),
      isNull,
    );
  });
}
