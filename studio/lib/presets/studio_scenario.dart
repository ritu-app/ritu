import '../models/cycle_history_draft.dart';
import 'cycle_presets.dart';

/// Scenarios shown in the playground. A subset of [CyclePreset], plus an
/// empty history and an open current period.
enum StudioScenario {
  regularCycle('Regular cycle'),
  variableCycle('Variable cycle'),
  unpredictableCycle('Unpredictable cycle'),
  newToRitu('New to Ritu (no cycles yet)'),
  threeCycles('Exactly 3 cycles – card just unlocked'),
  periodInProgress('Period in progress (open, not confirmed)');

  const StudioScenario(this.label);

  final String label;

  CycleHistoryDraft historyDraft() {
    return switch (this) {
      StudioScenario.regularCycle => CycleHistoryDraft.fromPreset(
        CyclePreset.regular,
      ),
      StudioScenario.variableCycle => CycleHistoryDraft.fromPreset(
        CyclePreset.variable,
      ),
      StudioScenario.unpredictableCycle => CycleHistoryDraft.fromPreset(
        CyclePreset.unpredictable,
      ),
      StudioScenario.newToRitu => CycleHistoryDraft(
        currentCycleDay: 1,
        rows: const [],
      ),
      StudioScenario.threeCycles => CycleHistoryDraft.fromPreset(
        CyclePreset.threshold3,
      ),
      StudioScenario.periodInProgress => CycleHistoryDraft.fromPreset(
        CyclePreset.regular,
      ).copyWith(currentCycleDay: 3, currentPeriodOpen: true),
    };
  }
}
