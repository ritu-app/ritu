import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/repositories/period_repository.dart';

import '../models/cycle_history_draft.dart';
import '../scope/ritu_repos.dart';

/// One-click period-history fixtures backed by the cycle engine spec tables.
enum CyclePreset {
  partial1(
    label: 'Partial — 1 cycle',
    cycleLengths: [28],
    targetCycleDay: 14,
  ),
  partial2(
    label: 'Partial — 2 cycles',
    cycleLengths: [28, 28],
    targetCycleDay: 14,
  ),
  threshold3(
    label: 'Threshold — 3 cycles',
    cycleLengths: [28, 27, 29],
    targetCycleDay: 14,
  ),
  regular(
    label: 'Regular',
    cycleLengths: [28, 27, 29, 28, 27, 28],
    targetCycleDay: 10,
  ),
  variable(
    label: 'Variable',
    cycleLengths: [21, 35, 23, 33, 25, 31],
    targetCycleDay: 14,
  ),
  unpredictable(
    label: 'Unpredictable',
    cycleLengths: [21, 46, 24, 43, 22, 40],
    targetCycleDay: 14,
  ),
  tierBShortCycle(
    label: 'Tier B — short cycle',
    cycleLengths: [21, 21, 21],
    targetCycleDay: 10,
    periodDuration: 5,
  ),
  tierCIrregular(
    label: 'Tier C — irregular',
    cycleLengths: [14, 14, 14],
    targetCycleDay: 10,
    periodDuration: 5,
  ),
  phaseDayMatrix(
    label: 'Phase day matrix',
    cycleLengths: [28, 27, 29, 28, 27, 28],
    targetCycleDay: 10,
  );

  const CyclePreset({
    required this.label,
    required this.cycleLengths,
    required this.targetCycleDay,
    this.periodDuration = defaultPeriodDuration,
  });

  final String label;
  final List<int> cycleLengths;
  final int targetCycleDay;
  final int periodDuration;

  static const defaultPeriodDuration = 5;
  static const defaultCycleLength = 28;
}

Future<void> clearPeriodHistory(PeriodRepository periods) async {
  final existing = await periods.getAll();
  for (final period in existing) {
    await periods.deleteByStartedOn(period.startedOn);
  }
}

Future<void> applyHistoryDraft(
  RituRepos repos,
  CycleHistoryDraft draft,
  DateTime simulatedToday,
) async {
  await clearPeriodHistory(repos.periods);
  if (draft.rows.isEmpty) return;

  final today = dateOnly(simulatedToday);
  var cursor = today.subtract(Duration(days: draft.currentCycleDay - 1));

  for (var i = draft.rows.length - 1; i >= 0; i--) {
    final row = draft.rows[i];
    await repos.periods.upsertPeriod(
      startedOn: cursor,
      endedOn: PeriodRepository.estimateEnd(cursor, row.periodDuration),
      source: PeriodSources.settings,
    );
    if (i > 0) {
      final length = row.cycleLength ?? CyclePreset.defaultCycleLength;
      cursor = dateOnly(cursor).subtract(Duration(days: length));
    }
  }
}

Future<void> applyPreset(
  RituRepos repos,
  CyclePreset preset,
  DateTime simulatedToday,
) {
  return applyHistoryDraft(
    repos,
    CycleHistoryDraft.fromPreset(preset),
    simulatedToday,
  );
}
