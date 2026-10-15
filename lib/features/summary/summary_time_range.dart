import '../../core/date_format.dart';

/// Time range choices on the generate-summary sheet (Figma 965-3320).
enum SummaryTimeRange {
  last30Days,
  last3Months,
  last6Months,
  currentCycle,
  previousCycle,
  custom,
}

extension SummaryTimeRangeX on SummaryTimeRange {
  String get label => switch (this) {
    SummaryTimeRange.last30Days => 'Last 30 days',
    SummaryTimeRange.last3Months => 'Last 3 months',
    SummaryTimeRange.last6Months => 'Last 6 months',
    SummaryTimeRange.currentCycle => 'Current cycle',
    SummaryTimeRange.previousCycle => 'Previous cycle',
    SummaryTimeRange.custom => 'Custom',
  };
}

/// Inclusive calendar window for a summary time range.
class SummaryDateWindow {
  const SummaryDateWindow({this.start, required this.end});

  /// Null when the range cannot be resolved (no cycle to show).
  final DateTime? start;
  final DateTime end;

  bool get isEmpty => start == null;

  bool contains(DateTime day) {
    final startDay = start;
    if (startDay == null) return false;
    final date = dateOnly(day);
    return !date.isBefore(dateOnly(startDay)) && !date.isAfter(dateOnly(end));
  }
}

/// Resolves [range] against [today] and logged period starts.
///
/// [periodStarts] may be in any order. Current cycle begins on the latest
/// start. Previous cycle runs from the start before that through the day
/// before the current start.
SummaryDateWindow summaryWindow({
  required SummaryTimeRange range,
  required DateTime today,
  required List<DateTime> periodStarts,
  DateTime? customFrom,
  DateTime? customTo,
}) {
  final day = dateOnly(today);
  final starts = periodStarts.map(dateOnly).toList()..sort();

  return switch (range) {
    SummaryTimeRange.last30Days => SummaryDateWindow(
      start: day.subtract(const Duration(days: 29)),
      end: day,
    ),
    SummaryTimeRange.last3Months => SummaryDateWindow(
      start: DateTime(day.year, day.month - 3, day.day),
      end: day,
    ),
    SummaryTimeRange.last6Months => SummaryDateWindow(
      start: DateTime(day.year, day.month - 6, day.day),
      end: day,
    ),
    SummaryTimeRange.currentCycle =>
      starts.isEmpty
          ? SummaryDateWindow(end: day)
          : SummaryDateWindow(start: starts.last, end: day),
    SummaryTimeRange.previousCycle => _previousCycle(starts, day),
    SummaryTimeRange.custom => _customWindow(customFrom, customTo, day),
  };
}

SummaryDateWindow _previousCycle(
  List<DateTime> startsOldestFirst,
  DateTime today,
) {
  if (startsOldestFirst.length < 2) return SummaryDateWindow(end: today);
  final currentStart = startsOldestFirst.last;
  final previousStart = startsOldestFirst[startsOldestFirst.length - 2];
  final end = currentStart.subtract(const Duration(days: 1));
  if (end.isBefore(previousStart)) return SummaryDateWindow(end: today);
  return SummaryDateWindow(start: previousStart, end: end);
}

SummaryDateWindow _customWindow(DateTime? from, DateTime? to, DateTime today) {
  if (from == null || to == null) return SummaryDateWindow(end: today);
  final start = dateOnly(from);
  final end = dateOnly(to);
  if (end.isBefore(start)) {
    return SummaryDateWindow(start: end, end: start);
  }
  return SummaryDateWindow(start: start, end: end);
}

/// Phrase after "Showing entries from " on the journal picker.
String summaryRangePhrase({
  required SummaryTimeRange range,
  DateTime? customFrom,
  DateTime? customTo,
}) {
  return switch (range) {
    SummaryTimeRange.last30Days => 'the last 30 days',
    SummaryTimeRange.last3Months => 'the last 3 months',
    SummaryTimeRange.last6Months => 'the last 6 months',
    SummaryTimeRange.currentCycle => 'the current cycle',
    SummaryTimeRange.previousCycle => 'the previous cycle',
    SummaryTimeRange.custom =>
      customFrom == null || customTo == null
          ? 'your dates'
          : '${formatShortMonthDay(customFrom)} – ${formatShortMonthDayYear(customTo)}',
  };
}
