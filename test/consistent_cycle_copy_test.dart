import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle_classification.dart';
import 'package:ritu/features/insights/consistent_cycle_copy.dart';

void main() {
  test('describes a regular sample of at least three cycles', () {
    final copy = consistentCycleCopy(
      classification: CycleClassification.regular,
      cycleLengths: const [27, 28, 27],
    );

    expect(
      copy?.body,
      'Last 3 cycles: 27, 28, 27 days. Healthy stable variation',
    );
    expect(copy?.average, 'Average 27.3 days');
  });

  test('uses only the three most recent cycles', () {
    final copy = consistentCycleCopy(
      classification: CycleClassification.regular,
      cycleLengths: const [21, 40, 30, 28, 26],
    );

    expect(
      copy?.body,
      'Last 3 cycles: 30, 28, 26 days. Healthy stable variation',
    );
    expect(copy?.average, 'Average 28.0 days');
  });

  test('stays hidden until the cycle is regular', () {
    expect(
      consistentCycleCopy(
        classification: CycleClassification.variable,
        cycleLengths: const [24, 32, 29],
      ),
      isNull,
    );
    expect(
      consistentCycleCopy(
        classification: CycleClassification.regular,
        cycleLengths: const [28, 28],
      ),
      isNull,
    );
  });
}
