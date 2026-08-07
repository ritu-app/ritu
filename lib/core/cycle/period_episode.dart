import '../date_format.dart';

/// Minimal period episode for cycle math — no persistence types.
class PeriodEpisode {
  const PeriodEpisode({
    required this.startedOn,
    this.endedOn,
  });

  final DateTime startedOn;
  final DateTime? endedOn;

  /// Inclusive bleed-day count for [P] (period duration).
  ///
  /// When [endedOn] is null (active period), counts through [throughDate].
  int periodDuration({required DateTime throughDate}) {
    final start = dateOnly(startedOn);
    final end = endedOn == null ? dateOnly(throughDate) : dateOnly(endedOn!);
    if (end.isBefore(start)) return 1;
    return end.difference(start).inDays + 1;
  }
}
