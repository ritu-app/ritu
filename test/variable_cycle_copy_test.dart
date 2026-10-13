import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle_classification.dart';
import 'package:ritu/features/insights/variable_cycle_copy.dart';

void main() {
  test('describes the shortest and longest lengths in the sample', () {
    final copy = variableCycleCopy(
      classification: CycleClassification.variable,
      cycleLengths: const [24, 28, 33],
    );

    expect(copy?.title, 'Cycle length varies - 24 to 33 days');
    expect(copy?.recorded, '3 cycles recorded');
  });

  test('counts every length in the rolling sample', () {
    final copy = variableCycleCopy(
      classification: CycleClassification.variable,
      cycleLengths: const [21, 35, 23, 33, 25, 31],
    );

    expect(copy?.title, 'Cycle length varies - 21 to 35 days');
    expect(copy?.recorded, '6 cycles recorded');
  });

  test('stays hidden until the cycle is variable', () {
    expect(
      variableCycleCopy(
        classification: CycleClassification.regular,
        cycleLengths: const [24, 32, 29],
      ),
      isNull,
    );
    expect(
      variableCycleCopy(
        classification: CycleClassification.variable,
        cycleLengths: const [],
      ),
      isNull,
    );
  });
}
