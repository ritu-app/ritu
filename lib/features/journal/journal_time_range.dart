import '../../core/date_format.dart';

/// Time-range options for All entries (Figma 865:3625).
enum JournalTimeRange {
  last7Days,
  lastMonth,
  last3Months,
  currentCycle,
  previousCycle,
}

extension JournalTimeRangeX on JournalTimeRange {
  String get label => switch (this) {
        JournalTimeRange.last7Days => 'Last 7 days',
        JournalTimeRange.lastMonth => 'Last month',
        JournalTimeRange.last3Months => 'Last 3 months',
        JournalTimeRange.currentCycle => 'Current cycle',
        JournalTimeRange.previousCycle => 'Previous cycle',
      };

  /// Cycle-based ranges are shown in the sheet but not selectable yet.
  bool get isEnabled => switch (this) {
        JournalTimeRange.currentCycle ||
        JournalTimeRange.previousCycle =>
          false,
        _ => true,
      };

  /// Inclusive lower bound for [loggedOn], relative to [today] (date-only).
  /// Returns null when the range is not implemented.
  DateTime? startOnOrAfter(DateTime today) {
    final day = dateOnly(today);
    return switch (this) {
      JournalTimeRange.last7Days => day.subtract(const Duration(days: 7)),
      JournalTimeRange.lastMonth => day.subtract(const Duration(days: 30)),
      JournalTimeRange.last3Months => day.subtract(const Duration(days: 90)),
      JournalTimeRange.currentCycle ||
      JournalTimeRange.previousCycle =>
        null,
    };
  }
}
