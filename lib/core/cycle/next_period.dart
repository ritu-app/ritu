import '../date_format.dart';

/// Predicted next period start from the latest start and effective cycle length [C].
///
/// Cycle length is start-to-start, so next = lastStart + C days.
DateTime? nextPeriodStart({
  required DateTime? lastPeriodStartedOn,
  required int? effectiveCycleLength,
}) {
  if (lastPeriodStartedOn == null || effectiveCycleLength == null) {
    return null;
  }
  if (effectiveCycleLength < 1) return null;
  return dateOnly(lastPeriodStartedOn).add(Duration(days: effectiveCycleLength));
}
