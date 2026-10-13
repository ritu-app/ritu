import '../models/cycle_history_draft.dart';
import 'cycle_presets.dart';

/// How many past days (not including today) get a daily-log check-in.
enum DailyLogDensity {
  none('None'),
  sparse('Sparse'),
  full('Full');

  const DailyLogDensity(this.label);

  final String label;

  /// Past days, excluding today.
  ///
  /// [sparse] is longer than two cycles and shorter than three.
  /// [full] is longer than three cycles.
  int pastDays(CycleHistoryDraft draft) => switch (this) {
    DailyLogDensity.none => 0,
    DailyLogDensity.sparse => _withinHistory(
      sparseDailyLogPastDays(draft),
      draft,
    ),
    DailyLogDensity.full => _withinHistory(fullDailyLogPastDays(draft), draft),
  };
}

int _withinHistory(int days, CycleHistoryDraft draft) {
  final span = draft.historyPastDays;
  if (days > span) return span;
  if (days < 0) return 0;
  return days;
}

/// Past days, excluding today, longer than two cycles and shorter than three.
///
/// One day past the two most recent completed lengths and the days already
/// elapsed in the current cycle. Missing lengths use the default cycle.
int sparseDailyLogPastDays(CycleHistoryDraft draft) {
  final completed = _completedLengths(draft);
  final elapsed = _elapsedBeforeToday(draft);
  final two = _span(completed, 2, elapsed);
  final three = _span(completed, 3, elapsed);
  final moreThanTwo = two + 1;
  if (moreThanTwo < three) return moreThanTwo;
  return three > two ? three - 1 : moreThanTwo;
}

/// Past days, excluding today, spanning more than three cycles.
///
/// Uses the three most recent completed lengths plus days already elapsed
/// in the current cycle, then one more day so the range is longer than
/// three cycles even on cycle day 1. Missing lengths use the default cycle.
int fullDailyLogPastDays(CycleHistoryDraft draft) {
  return _span(_completedLengths(draft), 3, _elapsedBeforeToday(draft)) + 1;
}

List<int> _completedLengths(CycleHistoryDraft draft) {
  return [
    for (final row in draft.rows)
      if (row.cycleLength != null && row.cycleLength! > 0) row.cycleLength!,
  ];
}

int _elapsedBeforeToday(CycleHistoryDraft draft) {
  return draft.currentCycleDay > 1 ? draft.currentCycleDay - 1 : 0;
}

int _span(List<int> completed, int cycles, int elapsed) {
  final recent = completed.length <= cycles
      ? completed
      : completed.sublist(completed.length - cycles);
  final lengths = [
    for (var i = recent.length; i < cycles; i++) CyclePreset.defaultCycleLength,
    ...recent,
  ];
  return lengths.fold<int>(0, (sum, length) => sum + length) + elapsed;
}

/// How journal entries are spread across logged history.
enum JournalDensity {
  off(0, false, 'Off'),
  occasional(3, false, 'Occasional'),
  daily(13, true, 'Daily');

  const JournalDensity(this.pastCount, this.includesToday, this.label);

  /// Cap for [occasional] entries before simulated today.
  ///
  /// [daily] ignores this and fills every past day in the cycle history.
  final int pastCount;

  /// Whether simulated today also has an entry when history covers today.
  final bool includesToday;

  final String label;

  /// Past entries that fall on or after the earliest period start.
  int pastEntries(CycleHistoryDraft draft) {
    final span = draft.historyPastDays;
    return switch (this) {
      JournalDensity.off => 0,
      JournalDensity.occasional => span < pastCount ? span : pastCount,
      JournalDensity.daily => span,
    };
  }

  /// Today is seeded only when this density includes it and a cycle exists.
  bool logsToday(CycleHistoryDraft draft) =>
      includesToday && draft.rows.isNotEmpty;
}
