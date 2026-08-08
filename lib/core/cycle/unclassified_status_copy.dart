/// Trailing footer copy for the unclassified home status card.
///
/// Soft-horizon card while insights are still learning:
/// - 1 period start, fewer than 2 weeks into that cycle → "No history yet"
/// - 1 period start, 2+ weeks into that cycle → "N weeks so far"
///   (elapsed time in the current cycle — not past-period history)
/// - 2+ period starts (still < 3 completed cycles) → "N cycles so far"
String unclassifiedStatusTrailingLabel({
  required int periodStartCount,
  required int? cycleDay,
}) {
  if (periodStartCount >= 2) {
    return '$periodStartCount cycles so far';
  }

  final day = cycleDay ?? 0;
  final weeks = day ~/ 7;
  if (weeks >= 2) {
    return '$weeks weeks so far';
  }
  return 'No history yet';
}
