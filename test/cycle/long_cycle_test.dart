import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle.dart';

void main() {
  group('isCycleLongerThanUsual', () {
    test(
      'regular stays phased through the average and drops the day after',
      () {
        expect(
          isCycleLongerThanUsual(
            classification: CycleClassification.regular,
            cycleDay: 28,
            effectiveCycleLength: 28,
            sampleCycleLengths: const [28, 28, 28],
          ),
          isFalse,
        );
        expect(
          isCycleLongerThanUsual(
            classification: CycleClassification.regular,
            cycleDay: 29,
            effectiveCycleLength: 28,
            sampleCycleLengths: const [28, 28, 28],
          ),
          isTrue,
        );
      },
    );

    test('variable waits until the day after the longest sample cycle', () {
      const sample = [21, 35, 23, 33, 25, 31];
      expect(
        isCycleLongerThanUsual(
          classification: CycleClassification.variable,
          cycleDay: 35,
          effectiveCycleLength: 28,
          sampleCycleLengths: sample,
        ),
        isFalse,
      );
      expect(
        isCycleLongerThanUsual(
          classification: CycleClassification.variable,
          cycleDay: 36,
          effectiveCycleLength: 28,
          sampleCycleLengths: sample,
        ),
        isTrue,
      );
    });

    test('unpredictable and unclassified never use this fallback', () {
      expect(
        isCycleLongerThanUsual(
          classification: CycleClassification.unpredictable,
          cycleDay: 60,
          effectiveCycleLength: null,
          sampleCycleLengths: const [21, 46, 22],
        ),
        isFalse,
      );
      expect(
        isCycleLongerThanUsual(
          classification: CycleClassification.unclassified,
          cycleDay: 40,
          effectiveCycleLength: null,
          sampleCycleLengths: const [],
        ),
        isFalse,
      );
    });
  });

  test('usualCycleLengthLabel uses the personal length', () {
    expect(usualCycleLengthDays(effectiveCycleLength: 26), 26);
    expect(usualCycleLengthLabel(26), 'Usually 26 days');
    expect(usualCycleLengthLabel(1), 'Usually 1 day');
  });
}
