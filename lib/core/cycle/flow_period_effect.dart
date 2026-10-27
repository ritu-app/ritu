import '../date_format.dart';

/// Flow values that mean bleeding. `None` and a skipped answer do not.
const bleedingFlowIntensities = {'Spotting', 'Light', 'Medium', 'Heavy'};

/// A period stays one episode through this many days from its start.
///
/// Flow after this cap starts a new episode. See the period-boundary spec.
const maxSamePeriodDays = 10;

/// Used when the profile has no typical period length yet.
const defaultAssumedPeriodDays = 5;

/// One stored period, reduced to what flow logging needs to decide.
class FlowPeriodSnapshot {
  const FlowPeriodSnapshot({
    required this.startedOn,
    required this.endConfirmed,
    required this.startedFromDailyLog,
    this.endedOn,
  });

  final DateTime startedOn;
  final DateTime? endedOn;

  /// User-confirmed end (exact, rough, or the day-10 cap). Estimated ends can
  /// still be extended by a later flow log.
  final bool endConfirmed;

  final bool startedFromDailyLog;
}

/// What saving a daily flow answer should do to period episodes.
sealed class FlowPeriodEffect {
  const FlowPeriodEffect();
}

/// No period row should change.
class NoFlowPeriodEffect extends FlowPeriodEffect {
  const NoFlowPeriodEffect();
}

/// Bleeding outside the current episode starts a new logged period.
class StartLoggedPeriod extends FlowPeriodEffect {
  const StartLoggedPeriod({required this.startedOn, required this.endedOn});

  final DateTime startedOn;

  /// Inclusive assumed end so the hero can leave menstrual after the usual
  /// length if the user goes quiet.
  final DateTime endedOn;
}

/// Bleeding still belongs to the episode that started within the last 10 days.
class ExtendPeriodThrough extends FlowPeriodEffect {
  const ExtendPeriodThrough({required this.startedOn, required this.endedOn});

  final DateTime startedOn;
  final DateTime endedOn;
}

/// The user took back the flow answer that opened this episode.
class RemoveLoggedPeriodStart extends FlowPeriodEffect {
  const RemoveLoggedPeriodStart(this.startedOn);

  final DateTime startedOn;
}

bool isBleedingFlow(String? flowIntensity) =>
    bleedingFlowIntensities.contains(flowIntensity);

/// Decides how a saved flow answer updates period episodes.
///
/// Any bleeding value starts a period when the user is outside one. Flow
/// inside 10 days of an unconfirmed episode extends that episode instead, so
/// a short gap does not become a fake new cycle. A confirmed end, or day 11
/// onward, starts a new episode and the cycle day resets to 1.
FlowPeriodEffect effectForFlowLog({
  required DateTime loggedOn,
  required String? flowIntensity,
  required List<FlowPeriodSnapshot> periods,
  int? typicalPeriodDays,
}) {
  final day = dateOnly(loggedOn);
  final current = _episodeOnOrBefore(day, periods);
  final bleeding = isBleedingFlow(flowIntensity);

  if (current != null && isSameCalendarDay(current.startedOn, day)) {
    if (!bleeding && current.startedFromDailyLog) {
      return RemoveLoggedPeriodStart(day);
    }
    return const NoFlowPeriodEffect();
  }

  if (!bleeding) return const NoFlowPeriodEffect();

  if (current == null) {
    return StartLoggedPeriod(
      startedOn: day,
      endedOn: assumedPeriodEnd(day, typicalPeriodDays),
    );
  }

  final start = dateOnly(current.startedOn);
  final end = current.endedOn == null ? null : dateOnly(current.endedOn!);
  final dayIndex = day.difference(start).inDays + 1;
  final alreadyBleeding = end == null || !day.isAfter(end);
  if (alreadyBleeding) return const NoFlowPeriodEffect();

  final pastSamePeriodWindow = dayIndex > maxSamePeriodDays;
  if (pastSamePeriodWindow || current.endConfirmed) {
    return StartLoggedPeriod(
      startedOn: day,
      endedOn: assumedPeriodEnd(day, typicalPeriodDays),
    );
  }

  return ExtendPeriodThrough(startedOn: start, endedOn: day);
}

/// Inclusive end from a typical length, falling back to 5 days.
DateTime assumedPeriodEnd(DateTime startedOn, int? typicalPeriodDays) {
  final days = typicalPeriodDays != null && typicalPeriodDays >= 1
      ? typicalPeriodDays
      : defaultAssumedPeriodDays;
  return dateOnly(startedOn).add(Duration(days: days - 1));
}

FlowPeriodSnapshot? _episodeOnOrBefore(
  DateTime day,
  List<FlowPeriodSnapshot> periods,
) {
  FlowPeriodSnapshot? latest;
  for (final period in periods) {
    final start = dateOnly(period.startedOn);
    if (start.isAfter(day)) continue;
    if (latest == null || start.isAfter(dateOnly(latest.startedOn))) {
      latest = period;
    }
  }
  return latest;
}
