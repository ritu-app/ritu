import 'package:flutter_test/flutter_test.dart';
import 'package:ritu_studio/models/cycle_history_draft.dart';
import 'package:ritu_studio/presets/cycle_presets.dart';
import 'package:ritu_studio/presets/logged_density.dart';

void main() {
  test('full covers more than three cycles of the current history', () {
    final regular = CycleHistoryDraft.fromPreset(CyclePreset.regular);
    final days = DailyLogDensity.full.pastDays(regular);
    final lengths = CyclePreset.regular.cycleLengths;
    final threeCycles =
        lengths.sublist(lengths.length - 3).fold<int>(
          0,
          (sum, length) => sum + length,
        ) +
        (regular.currentCycleDay - 1);

    expect(days, greaterThan(threeCycles));
    expect(days, threeCycles + 1);
  });

  test('logs and journal stay inside the cycle history window', () {
    final partial = CycleHistoryDraft.fromPreset(CyclePreset.partial1);
    final empty = CycleHistoryDraft(currentCycleDay: 1, rows: const []);
    final regular = CycleHistoryDraft.fromPreset(CyclePreset.regular);

    expect(DailyLogDensity.full.pastDays(partial), partial.historyPastDays);
    expect(DailyLogDensity.sparse.pastDays(partial), partial.historyPastDays);
    expect(DailyLogDensity.full.pastDays(empty), 0);
    expect(DailyLogDensity.none.pastDays(empty), 0);
    expect(JournalDensity.daily.pastEntries(empty), 0);
    expect(JournalDensity.daily.logsToday(empty), isFalse);

    expect(
      JournalDensity.daily.pastEntries(regular),
      regular.historyPastDays,
    );
    expect(JournalDensity.occasional.pastEntries(regular), 3);
    expect(
      JournalDensity.occasional.pastEntries(partial) <= partial.historyPastDays,
      isTrue,
    );
    expect(JournalDensity.daily.logsToday(regular), isTrue);
  });

  test('sparse covers more than two cycles and less than three', () {
    final regular = CycleHistoryDraft.fromPreset(CyclePreset.regular);
    final lengths = CyclePreset.regular.cycleLengths;
    final elapsed = regular.currentCycleDay - 1;
    final twoCycles =
        lengths.sublist(lengths.length - 2).fold<int>(0, (sum, n) => sum + n) +
        elapsed;
    final threeCycles =
        lengths.sublist(lengths.length - 3).fold<int>(0, (sum, n) => sum + n) +
        elapsed;
    final days = DailyLogDensity.sparse.pastDays(regular);

    expect(days, greaterThan(twoCycles));
    expect(days, lessThan(threeCycles));
    expect(days, lessThan(regular.historyPastDays));
  });
}
