import 'cycle_phase.dart';
import 'day_range.dart';

/// Computed phase boundaries for one cycle.
class PhaseRanges {
  const PhaseRanges({
    required this.tier,
    required this.menstrual,
    this.follicular,
    this.ovulatory,
    this.luteal,
  });

  final PhaseTier tier;
  final DayRange menstrual;
  final DayRange? follicular;
  final DayRange? ovulatory;
  final DayRange? luteal;

  /// Phase for [cycleDay], or null when no estimate applies (Tier C).
  CyclePhase? phaseForDay(int cycleDay) {
    if (menstrual.contains(cycleDay)) return CyclePhase.menstrual;
    if (follicular?.contains(cycleDay) ?? false) return CyclePhase.follicular;
    if (ovulatory?.contains(cycleDay) ?? false) return CyclePhase.ovulatory;
    if (luteal?.contains(cycleDay) ?? false) return CyclePhase.luteal;
    return null;
  }
}

/// Available post-period days: [C - P].
int availablePostPeriodDays(int periodDuration, int cycleLength) {
  return cycleLength - periodDuration;
}

/// Determines compression tier before range calculation.
///
/// See [docs/cycle-phase-range-spec.html] §4.
PhaseTier phaseTier({
  required int periodDuration,
  required int cycleLength,
}) {
  if (cycleLength <= periodDuration) return PhaseTier.irregular;

  final available = availablePostPeriodDays(periodDuration, cycleLength);
  if (available >= 17) return PhaseTier.normal;
  if (available >= 15) return PhaseTier.compressed;
  return PhaseTier.irregular;
}

/// Computes phase day ranges from period duration [P] and cycle length [C].
///
/// Returns ranges with null phases for Tier C (irregular).
PhaseRanges computePhaseRanges({
  required int periodDuration,
  required int cycleLength,
}) {
  final tier = phaseTier(
    periodDuration: periodDuration,
    cycleLength: cycleLength,
  );

  final menstrual = DayRange(start: 1, end: periodDuration);

  if (tier == PhaseTier.irregular) {
    return PhaseRanges(
      tier: tier,
      menstrual: menstrual,
    );
  }

  if (tier == PhaseTier.compressed) {
    final available = availablePostPeriodDays(periodDuration, cycleLength);
    final ovulatoryLength = available - 14;
    final ovulatoryStart = periodDuration + 1;
    return PhaseRanges(
      tier: tier,
      menstrual: menstrual,
      ovulatory: DayRange(
        start: ovulatoryStart,
        end: ovulatoryStart + ovulatoryLength - 1,
      ),
      luteal: DayRange(start: cycleLength - 13, end: cycleLength),
    );
  }

  // Tier A — standard formula.
  return PhaseRanges(
    tier: tier,
    menstrual: DayRange(start: 1, end: periodDuration),
    follicular: DayRange(start: periodDuration + 1, end: cycleLength - 17),
    ovulatory: DayRange(start: cycleLength - 16, end: cycleLength - 14),
    luteal: DayRange(start: cycleLength - 13, end: cycleLength),
  );
}
