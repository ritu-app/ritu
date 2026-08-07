import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/repositories/period_repository.dart';

import '../models/cycle_history_draft.dart';
import '../scope/ritu_repos.dart';

/// One-click period-history fixtures backed by the cycle engine spec tables.
enum CyclePreset {
  partial1(
    label: 'Partial — 1 cycle',
    description:
        '1 completed cycle (2 period starts). Cycle lengths: [28]. '
        'P=5, current cycle day 14. Insights: partial. Classification: unclassified.',
    cycleLengths: [28],
    targetCycleDay: 14,
  ),
  partial2(
    label: 'Partial — 2 cycles',
    description:
        '2 completed cycles (3 period starts). Cycle lengths: [28, 28]. '
        'P=5, day 14. Insights: partial. Classification: unclassified.',
    cycleLengths: [28, 28],
    targetCycleDay: 14,
  ),
  threshold3(
    label: 'Threshold — 3 cycles',
    description:
        '3 completed cycles (4 period starts). Cycle lengths: [28, 27, 29]. '
        'P=5, day 14. First preset at the full-insights threshold (≥3 completed). '
        'Classification computed from sample.',
    cycleLengths: [28, 27, 29],
    targetCycleDay: 14,
  ),
  regular(
    label: 'Regular',
    description:
        '6 completed cycles (7 period starts). Cycle lengths: [28, 27, 29, 28, 27, 28]. '
        'P=5, day 10 (follicular). Expect Regular, MAD ≈ 0.6, effective C ≈ 28, Tier A.',
    cycleLengths: [28, 27, 29, 28, 27, 28],
    targetCycleDay: 10,
  ),
  variable(
    label: 'Variable',
    description:
        '6 completed cycles. Cycle lengths: [21, 35, 23, 33, 25, 31]. '
        'P=5, day 14. Expect Variable, MAD ≈ 5.0, estimated phases.',
    cycleLengths: [21, 35, 23, 33, 25, 31],
    targetCycleDay: 14,
  ),
  unpredictable(
    label: 'Unpredictable',
    description:
        '6 completed cycles. Cycle lengths: [21, 46, 24, 43, 22, 40]. '
        'P=5, day 14. Expect Unpredictable, MAD ≈ 10.3, no phase estimates.',
    cycleLengths: [21, 46, 24, 43, 22, 40],
    targetCycleDay: 14,
  ),
  tierBShortCycle(
    label: 'Tier B — short cycle',
    description:
        '3 completed cycles. Cycle lengths: [21, 21, 21]. P=5, day 10. '
        'Regular classification with effective C=21 → Tier B (compressed; follicular omitted).',
    cycleLengths: [21, 21, 21],
    targetCycleDay: 10,
    periodDuration: 5,
  ),
  tierCIrregular(
    label: 'Tier C — irregular',
    description:
        '3 completed cycles. Cycle lengths: [14, 14, 14]. P=5, day 10. '
        'Effective C=14 (available < 15) → Tier C irregular; no phase estimates.',
    cycleLengths: [14, 14, 14],
    targetCycleDay: 10,
    periodDuration: 5,
  ),
  phaseDayMatrix(
    label: 'Phase day matrix',
    description:
        'Same period history as Regular (6 cycles, [28, 27, 29, 28, 27, 28]). '
        'P=5, day 10 baseline. Adjust current cycle day in the editor to walk each phase.',
    cycleLengths: [28, 27, 29, 28, 27, 28],
    targetCycleDay: 10,
  );

  const CyclePreset({
    required this.label,
    required this.description,
    required this.cycleLengths,
    required this.targetCycleDay,
    this.periodDuration = defaultPeriodDuration,
  });

  final String label;
  final String description;
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
