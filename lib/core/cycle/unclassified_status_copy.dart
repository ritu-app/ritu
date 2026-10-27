/// Cycle day at which an unclassified hero softens its tone.
///
/// The day count keeps climbing. This only adds a nudge; it is not an
/// overdue claim, because there is no personal average yet.
const quietPreclassificationCycleDay = 45;

/// True once an unclassified cycle has passed [quietPreclassificationCycleDay]
/// without a new period.
bool showQuietPreclassificationPrompt({
  required int periodStartCount,
  required int? cycleDay,
}) {
  if (periodStartCount < 1 || cycleDay == null) return false;
  return cycleDay >= quietPreclassificationCycleDay;
}

/// Trailing footer copy for the unclassified home status card.
///
/// - 1 period start: weeks from daily logs only ("1 week logged"). Calendar
///   days she did not log do not increase it.
/// - 2+ period starts (still short of classification): "N cycles so far"
String unclassifiedStatusTrailingLabel({
  required int periodStartCount,
  required int loggedDays,
}) {
  if (periodStartCount >= 2) {
    return '$periodStartCount cycles so far';
  }

  final weeks = loggedDays <= 0 ? 0 : loggedDays ~/ 7;
  if (weeks < 1) return 'No history yet';
  final unit = weeks == 1 ? 'week' : 'weeks';
  return '$weeks $unit logged';
}
