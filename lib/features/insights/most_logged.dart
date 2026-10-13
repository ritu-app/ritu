import '../../core/date_format.dart';
import '../../data/models/daily_log_entry.dart';
import 'insight_history.dart';

/// How many labels the most-logged row shows.
const mostLoggedLimit = 4;

/// The labels logged most often for [lens], highest count first.
///
/// Ties break alphabetically. Overview has no most-logged row. Logs after
/// [today] are ignored, matching the history heatmap.
List<String> mostLoggedLabels({
  required List<DailyLogEntry> logs,
  required DateTime today,
  required InsightLens lens,
  int limit = mostLoggedLimit,
}) {
  if (lens == InsightLens.overview || limit <= 0) return const [];

  final end = dateOnly(today);
  final counts = <String, int>{};
  for (final log in logs) {
    if (dateOnly(log.loggedOn).isAfter(end)) continue;
    for (final raw in _labels(log, lens)) {
      final label = raw.trim();
      if (label.isEmpty) continue;
      counts[label] = (counts[label] ?? 0) + 1;
    }
  }

  final ranked = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.toLowerCase().compareTo(b.key.toLowerCase());
    });
  return [for (final entry in ranked.take(limit)) entry.key];
}

Iterable<String> _labels(DailyLogEntry log, InsightLens lens) {
  return switch (lens) {
    InsightLens.overview => const [],
    InsightLens.mood => log.moods,
    InsightLens.energy => [if (log.energyLevel != null) log.energyLevel!],
    InsightLens.body => log.symptoms,
  };
}
