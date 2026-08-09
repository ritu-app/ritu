import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/next_period.dart';

void main() {
  test('next period is last start plus cycle length', () {
    expect(
      nextPeriodStart(
        lastPeriodStartedOn: DateTime(2026, 11, 14),
        effectiveCycleLength: 28,
      ),
      DateTime(2026, 12, 12),
    );
  });

  test('returns null without inputs', () {
    expect(
      nextPeriodStart(
        lastPeriodStartedOn: null,
        effectiveCycleLength: 28,
      ),
      isNull,
    );
    expect(
      nextPeriodStart(
        lastPeriodStartedOn: DateTime(2026, 11, 14),
        effectiveCycleLength: null,
      ),
      isNull,
    );
  });

  test('variable next period range uses shortest and longest sample', () {
    final range = nextPeriodRange(
      lastPeriodStartedOn: DateTime(2026, 9, 15),
      sampleCycleLengths: const [21, 35, 23, 33, 25, 31],
    );
    expect(range?.earliest, DateTime(2026, 10, 6)); // +21
    expect(range?.latest, DateTime(2026, 10, 20)); // +35
  });

  test('formatNextPeriodLabel regular is a single date', () {
    expect(
      formatNextPeriodLabel(
        lastPeriodStartedOn: DateTime(2026, 4, 1),
        effectiveCycleLength: 28,
        sampleCycleLengths: const [28, 28, 28],
        asRange: false,
      ),
      'Apr 29',
    );
  });

  test('formatNextPeriodLabel variable is an estimated range', () {
    expect(
      formatNextPeriodLabel(
        lastPeriodStartedOn: DateTime(2026, 9, 15),
        effectiveCycleLength: 28,
        sampleCycleLengths: const [24, 30, 27],
        asRange: true,
      ),
      '~Oct 9-15',
    );
  });
}
