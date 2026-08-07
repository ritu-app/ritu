import '../date_format.dart';
import 'cycle_lengths.dart';
import 'period_episode.dart';

/// 1-based cycle day for [date] within the most recent applicable period.
///
/// Returns null when no period start is on or before [date].
int? cycleDayForDate({
  required DateTime date,
  required List<PeriodEpisode> episodesNewestFirst,
}) {
  final day = dateOnly(date);
  PeriodEpisode? applicable;

  for (final episode in episodesNewestFirst) {
    final start = dateOnly(episode.startedOn);
    if (start.isAfter(day)) continue;
    if (applicable == null ||
        start.isAfter(dateOnly(applicable.startedOn))) {
      applicable = episode;
    }
  }

  if (applicable == null) return null;
  return day.difference(dateOnly(applicable.startedOn)).inDays + 1;
}

/// The period episode whose cycle contains [date], if any.
PeriodEpisode? activeEpisodeForDate({
  required DateTime date,
  required List<PeriodEpisode> episodesNewestFirst,
}) {
  final day = dateOnly(date);
  PeriodEpisode? applicable;

  for (final episode in episodesNewestFirst) {
    final start = dateOnly(episode.startedOn);
    if (start.isAfter(day)) continue;
    if (applicable == null ||
        start.isAfter(dateOnly(applicable.startedOn))) {
      applicable = episode;
    }
  }

  return applicable;
}

/// Sort episodes newest-first (typical repository order).
List<PeriodEpisode> sortEpisodesNewestFirst(List<PeriodEpisode> episodes) {
  return List<PeriodEpisode>.from(episodes)
    ..sort((a, b) => b.startedOn.compareTo(a.startedOn));
}

/// Build oldest-first cycle lengths from episodes in any order.
List<int> cycleLengthsFromEpisodes(List<PeriodEpisode> episodes) {
  final starts = episodes.map((e) => e.startedOn);
  return cycleLengthsFromStarts(sortPeriodStartsOldestFirst(starts));
}

/// Whether [date] falls on a logged bleed day for any episode.
bool isBleedDay({
  required DateTime date,
  required List<PeriodEpisode> episodes,
  required DateTime referenceDate,
}) {
  final day = dateOnly(date);
  for (final episode in episodes) {
    final start = dateOnly(episode.startedOn);
    final end = episode.endedOn == null
        ? dateOnly(referenceDate)
        : dateOnly(episode.endedOn!);
    if (day.isBefore(start)) continue;
    if (!day.isAfter(end)) return true;
  }
  return false;
}
