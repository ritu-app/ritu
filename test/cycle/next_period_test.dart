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
}
