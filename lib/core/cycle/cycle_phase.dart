/// Menstrual cycle phase for display and styling.
enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
}

/// How confidently a phase label is shown.
enum PhaseConfidence {
  /// Logged data (menstrual bleed days).
  logged,

  /// Calculated with high confidence (Regular classification).
  exact,

  /// Calculated estimate (Variable classification).
  estimated,
}

/// Compression tier when [C - P] is too small for the standard formula.
enum PhaseTier {
  /// Standard 4-phase layout.
  normal,

  /// Follicular omitted; 3-segment strip.
  compressed,

  /// No phase estimates (short cycle or logging error).
  irregular,
}
