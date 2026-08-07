import 'package:ritu/core/cycle/cycle.dart';
import 'package:ritu/data/models/period_log.dart';

/// Maps persistence [PeriodLog] rows to cycle math inputs.
List<PeriodEpisode> episodesFromPeriodLogs(List<PeriodLog> logs) {
  return logs
      .map(
        (log) => PeriodEpisode(
          startedOn: log.startedOn,
          endedOn: log.endedOn,
        ),
      )
      .toList();
}

/// Convenience wrapper around [computeCycleSnapshot].
CycleSnapshot cycleSnapshotFromPeriodLogs({
  required DateTime referenceDate,
  required List<PeriodLog> logs,
}) {
  return computeCycleSnapshot(
    referenceDate: referenceDate,
    episodes: episodesFromPeriodLogs(logs),
  );
}
