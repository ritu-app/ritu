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

/// Earliest/latest next-period starts from shortest/longest sample lengths.
({DateTime earliest, DateTime latest})? nextPeriodRange({
  required DateTime? lastPeriodStartedOn,
  required List<int> sampleCycleLengths,
}) {
  if (lastPeriodStartedOn == null || sampleCycleLengths.isEmpty) return null;

  var shortest = sampleCycleLengths.first;
  var longest = sampleCycleLengths.first;
  for (final length in sampleCycleLengths) {
    if (length < shortest) shortest = length;
    if (length > longest) longest = length;
  }
  if (shortest < 1 || longest < 1) return null;

  final start = dateOnly(lastPeriodStartedOn);
  return (
    earliest: start.add(Duration(days: shortest)),
    latest: start.add(Duration(days: longest)),
  );
}

/// Footer date fragment after "Next period ".
///
/// Regular: `Apr 29`. Variable: `~Oct 9-15` (or `~Oct 28-Nov 3` across months).
String? formatNextPeriodLabel({
  required DateTime? lastPeriodStartedOn,
  required int? effectiveCycleLength,
  required List<int> sampleCycleLengths,
  required bool asRange,
}) {
  if (asRange) {
    final range = nextPeriodRange(
      lastPeriodStartedOn: lastPeriodStartedOn,
      sampleCycleLengths: sampleCycleLengths,
    );
    if (range == null) return null;
    return formatEstimatedShortMonthDayRange(range.earliest, range.latest);
  }

  final next = nextPeriodStart(
    lastPeriodStartedOn: lastPeriodStartedOn,
    effectiveCycleLength: effectiveCycleLength,
  );
  if (next == null) return null;
  return formatShortMonthDay(next);
}
