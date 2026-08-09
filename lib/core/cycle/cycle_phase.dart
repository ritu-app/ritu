/// Menstrual cycle phase for display and styling.
enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
}

/// User-facing phase label, e.g. "Follicular phase".
///
/// When [estimated] is true (Variable classification), non-menstrual phases
/// are prefixed with `~` — e.g. "~Follicular phase". Menstrual stays exact
/// because bleed days are logged.
String phaseDisplayLabel(CyclePhase phase, {bool estimated = false}) {
  final label = switch (phase) {
    CyclePhase.menstrual => 'Menstrual phase',
    CyclePhase.follicular => 'Follicular phase',
    CyclePhase.ovulatory => 'Ovulatory phase',
    CyclePhase.luteal => 'Luteal phase',
  };
  if (estimated && phase != CyclePhase.menstrual) {
    return '~$label';
  }
  return label;
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
