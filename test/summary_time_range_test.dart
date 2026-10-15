import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/features/summary/summary_time_range.dart';

void main() {
  final today = DateTime(2026, 9, 15);

  test('last 30 days covers 30 inclusive days', () {
    final window = summaryWindow(
      range: SummaryTimeRange.last30Days,
      today: today,
      periodStarts: const [],
    );

    expect(window.start, DateTime(2026, 8, 17));
    expect(window.end, today);
    expect(window.contains(DateTime(2026, 8, 17)), isTrue);
    expect(window.contains(DateTime(2026, 8, 16)), isFalse);
  });

  test('last 3 and 6 months step back on the calendar', () {
    final three = summaryWindow(
      range: SummaryTimeRange.last3Months,
      today: today,
      periodStarts: const [],
    );
    final six = summaryWindow(
      range: SummaryTimeRange.last6Months,
      today: today,
      periodStarts: const [],
    );

    expect(three.start, DateTime(2026, 6, 15));
    expect(six.start, DateTime(2026, 3, 15));
    expect(three.end, today);
  });

  test('current and previous cycles follow period starts', () {
    final starts = [DateTime(2026, 7, 1), DateTime(2026, 8, 20)];
    final current = summaryWindow(
      range: SummaryTimeRange.currentCycle,
      today: today,
      periodStarts: starts,
    );
    final previous = summaryWindow(
      range: SummaryTimeRange.previousCycle,
      today: today,
      periodStarts: starts,
    );

    expect(current.start, DateTime(2026, 8, 20));
    expect(current.end, today);
    expect(previous.start, DateTime(2026, 7, 1));
    expect(previous.end, DateTime(2026, 8, 19));
  });

  test('an unknown cycle contains no days', () {
    final window = summaryWindow(
      range: SummaryTimeRange.previousCycle,
      today: today,
      periodStarts: [DateTime(2026, 8, 1)],
    );

    expect(window.isEmpty, isTrue);
    expect(window.contains(today), isFalse);
  });

  test('custom range is inclusive and swaps reversed dates', () {
    final window = summaryWindow(
      range: SummaryTimeRange.custom,
      today: today,
      periodStarts: const [],
      customFrom: DateTime(2026, 8, 20),
      customTo: DateTime(2026, 8, 10),
    );

    expect(window.start, DateTime(2026, 8, 10));
    expect(window.end, DateTime(2026, 8, 20));
    expect(window.contains(DateTime(2026, 8, 10)), isTrue);
    expect(window.contains(DateTime(2026, 8, 20)), isTrue);
  });

  test('range phrases name the window', () {
    expect(
      summaryRangePhrase(range: SummaryTimeRange.last3Months),
      'the last 3 months',
    );
    expect(
      summaryRangePhrase(
        range: SummaryTimeRange.custom,
        customFrom: DateTime(2026, 8, 10),
        customTo: DateTime(2026, 8, 17),
      ),
      'Aug 10 – Aug 17, 2026',
    );
  });
}
