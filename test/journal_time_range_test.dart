import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/features/journal/journal_time_range.dart';

void main() {
  final today = DateTime(2026, 8, 8);

  test('enabled ranges expose rolling start dates', () {
    expect(
      JournalTimeRange.last7Days.startOnOrAfter(today),
      DateTime(2026, 8, 1),
    );
    expect(
      JournalTimeRange.lastMonth.startOnOrAfter(today),
      DateTime(2026, 7, 9),
    );
    expect(
      JournalTimeRange.last3Months.startOnOrAfter(today),
      DateTime(2026, 5, 10),
    );
  });

  test('cycle ranges stay disabled and have no start', () {
    expect(JournalTimeRange.currentCycle.isEnabled, isFalse);
    expect(JournalTimeRange.previousCycle.isEnabled, isFalse);
    expect(JournalTimeRange.currentCycle.startOnOrAfter(today), isNull);
    expect(JournalTimeRange.previousCycle.startOnOrAfter(today), isNull);
  });
}
