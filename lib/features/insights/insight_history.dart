import '../../core/date_format.dart';
import '../../data/models/daily_log_entry.dart';

/// Which daily-log field the insights history heatmap is drawing.
enum InsightLens { overview, mood, energy, body }

/// One cell in the history heatmap.
///
/// [low], [mid], and [high] map to the peach / gold / green swatches.
/// [none] is a logged gap or an unanswered field ("No data").
enum InsightLevel { low, mid, high, none }

/// One calendar month of history, from the first logged day through today.
class InsightMonthStrip {
  const InsightMonthStrip({
    required this.month,
    required this.label,
    required this.levels,
  });

  /// First day of this calendar month.
  final DateTime month;

  /// Short month name, with the year when the range crosses a year boundary.
  final String label;
  final List<InsightLevel> levels;
}

const _lightMoods = {'Calm', 'Focused', 'Happy', 'Content'};
const _heavyMoods = {
  'Irritable',
  'Anxious',
  'Flat',
  'Sad',
  'Overwhelmed',
  'Restless',
};

/// Calendar days from the earliest log through [today], grouped by month.
///
/// Days inside that span with no log are [InsightLevel.none]. Logs dated
/// after [today] are left out so a simulated clock does not draw the future.
List<InsightMonthStrip> buildInsightHistory({
  required List<DailyLogEntry> logs,
  required DateTime today,
  required InsightLens lens,
}) {
  final end = dateOnly(today);
  final byDate = <DateTime, DailyLogEntry>{};
  DateTime? start;
  for (final log in logs) {
    final day = dateOnly(log.loggedOn);
    if (day.isAfter(end)) continue;
    byDate[day] = log;
    if (start == null || day.isBefore(start)) start = day;
  }
  if (start == null) return const [];

  final spansYears = start.year != end.year;
  final strips = <InsightMonthStrip>[];
  DateTime? currentMonth;
  var levels = <InsightLevel>[];

  var cursor = start;
  while (!cursor.isAfter(end)) {
    final month = DateTime(cursor.year, cursor.month);
    if (currentMonth != month) {
      if (currentMonth != null) {
        strips.add(
          InsightMonthStrip(
            month: currentMonth,
            label: _monthLabel(currentMonth, spansYears),
            levels: levels,
          ),
        );
      }
      currentMonth = month;
      levels = [];
    }
    levels.add(_levelFor(byDate[cursor], lens));
    cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
  }

  if (currentMonth != null) {
    strips.add(
      InsightMonthStrip(
        month: currentMonth,
        label: _monthLabel(currentMonth, spansYears),
        levels: levels,
      ),
    );
  }
  return strips;
}

String _monthLabel(DateTime month, bool spansYears) {
  final name = formatShortMonth(month);
  if (!spansYears) return name;
  return '$name ${month.year}';
}

InsightLevel _levelFor(DailyLogEntry? entry, InsightLens lens) {
  if (entry == null) return InsightLevel.none;
  return switch (lens) {
    InsightLens.overview => _wellbeingLevel(entry.wellbeing),
    InsightLens.mood => _moodLevel(entry.moods),
    InsightLens.energy => _energyLevel(entry.energyLevel),
    InsightLens.body => _bodyLevel(entry.symptoms),
  };
}

/// Overall wellbeing is a 0–10 slider (struggling → thriving).
InsightLevel _wellbeingLevel(int? value) {
  if (value == null) return InsightLevel.none;
  if (value <= 3) return InsightLevel.low;
  if (value <= 6) return InsightLevel.mid;
  return InsightLevel.high;
}

InsightLevel _energyLevel(String? energy) {
  return switch (energy) {
    'Drained' || 'Low' => InsightLevel.low,
    'Moderate' => InsightLevel.mid,
    'High' || 'Vibrant' => InsightLevel.high,
    _ => InsightLevel.none,
  };
}

/// Heavy is an unsettled mood, light is an easeful one, mixed is both.
InsightLevel _moodLevel(List<String> moods) {
  final hasLight = moods.any(_lightMoods.contains);
  final hasHeavy = moods.any(_heavyMoods.contains);
  if (hasLight && hasHeavy) return InsightLevel.mid;
  if (hasHeavy) return InsightLevel.low;
  if (hasLight) return InsightLevel.high;
  return InsightLevel.none;
}

/// Symptom count on a saved log. An empty list is "no signal", not a gap —
/// a missing day is handled before this is called.
InsightLevel _bodyLevel(List<String> symptoms) {
  if (symptoms.length >= 2) return InsightLevel.low;
  if (symptoms.length == 1) return InsightLevel.mid;
  return InsightLevel.high;
}
