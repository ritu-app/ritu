import '../../core/cycle/flow_period_effect.dart';
import '../../core/date_format.dart';
import '../../data/models/period_log.dart';
import '../../data/repositories/period_repository.dart';

/// Applies [effectForFlowLog] to stored period episodes.
///
/// Called when a daily check-in is saved. The hero reads menstrual state from
/// period episodes, not from the flow answer itself.
Future<void> applyFlowPeriodEffect({
  required PeriodRepository periods,
  required DateTime loggedOn,
  required String? flowIntensity,
  int? typicalPeriodDays,
}) async {
  final existing = await periods.getAll();
  final effect = effectForFlowLog(
    loggedOn: loggedOn,
    flowIntensity: flowIntensity,
    typicalPeriodDays: typicalPeriodDays,
    periods: [
      for (final period in existing)
        FlowPeriodSnapshot(
          startedOn: period.startedOn,
          endedOn: period.endedOn,
          endConfirmed: _endConfirmed(period),
          startedFromDailyLog:
              period.startSource == PeriodStartSources.dailyLog,
        ),
    ],
  );

  switch (effect) {
    case StartLoggedPeriod(:final startedOn, :final endedOn):
      await periods.upsertPeriod(
        startedOn: startedOn,
        endedOn: endedOn,
        source: PeriodSources.calendar,
        startSource: PeriodStartSources.dailyLog,
        startConfidence: PeriodStartConfidence.logged,
        endStatus: PeriodEndStatus.estimated,
        endSource: PeriodEndSources.assumedDuration,
        endConfidence: PeriodEndConfidence.estimated,
      );
    case ExtendPeriodThrough(:final startedOn, :final endedOn):
      PeriodLog? period;
      for (final log in existing) {
        if (isSameCalendarDay(log.startedOn, startedOn)) {
          period = log;
          break;
        }
      }
      if (period == null) return;
      await periods.upsertPeriod(
        startedOn: period.startedOn,
        endedOn: endedOn,
        source: period.source,
        startSource: period.startSource,
        startConfidence: period.startConfidence,
        endStatus: PeriodEndStatus.estimated,
        endSource: period.endSource ?? PeriodEndSources.assumedDuration,
        endConfidence: PeriodEndConfidence.estimated,
      );
    case RemoveLoggedPeriodStart(:final startedOn):
      await periods.deleteByStartedOn(startedOn);
    case NoFlowPeriodEffect():
      return;
  }
}

bool _endConfirmed(PeriodLog period) {
  return period.endStatus == PeriodEndStatus.exact ||
      period.endStatus == PeriodEndStatus.rough ||
      period.endStatus == PeriodEndStatus.autoCapped;
}
