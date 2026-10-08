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

  /// Label without the parenthetical or trailing clause.
  String get shortLabel {
    final paren = label.indexOf(' (');
    final dash = label.indexOf(' –');
    var end = label.length;
    if (paren >= 0 && paren < end) end = paren;
    if (dash >= 0 && dash < end) end = dash;
    return label.substring(0, end);
  }

  /// Furthest cycle day the playground slider can reach.
  int get maxCycleDay => switch (this) {
    StudioScenario.regularCycle ||
    StudioScenario.threeCycles ||
    StudioScenario.periodInProgress => 30,
    StudioScenario.variableCycle => 35,
    StudioScenario.unpredictableCycle => 40,
    StudioScenario.newToRitu => 28,
  };

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
