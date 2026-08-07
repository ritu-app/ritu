/// User-level cycle regularity from recent completed cycle lengths.
enum CycleClassification {
  /// Fewer than 3 completed cycles — no classification attempted.
  unclassified,

  /// MAD 0–4 days.
  regular,

  /// MAD 5–9 days.
  variable,

  /// MAD 10+ days.
  unpredictable,
}

/// Whether insights can use classification and phase estimates.
enum InsightsMode {
  /// Fewer than 3 completed cycles — teasers only.
  partial,

  /// At least 3 completed cycles — full phase/classification insights.
  full,
}
