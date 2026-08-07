/// Trailing footer copy for the unclassified home status card.
///
/// Figma Home variants (soft-horizon card, partial insights):
/// - 1 period start, fewer than 2 weeks into that cycle → "No history yet"
/// - 1 period start, 2+ weeks → "N weeks logged"
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
    return '$weeks weeks logged';
  }
  return 'No history yet';
}
