import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/models/period_log.dart';

import '../presets/cycle_presets.dart';

/// One row in the cycle-length editor (oldest → newest).
class CycleHistoryRow {
  CycleHistoryRow({
    this.cycleLength,
    this.periodDuration = CyclePreset.defaultPeriodDuration,
  });

  /// Days from the previous row's start to this row's start. Null on the oldest row.
  int? cycleLength;
  int periodDuration;

  CycleHistoryRow copyWith({
    int? cycleLength,
    int? periodDuration,
  }) {
    return CycleHistoryRow(
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
    );
  }
}

/// Editable period history relative to simulated today.
class CycleHistoryDraft {
  CycleHistoryDraft({
    required this.currentCycleDay,
    required this.rows,
  });

  final int currentCycleDay;
  final List<CycleHistoryRow> rows;

  CycleHistoryDraft copyWith({
    int? currentCycleDay,
    List<CycleHistoryRow>? rows,
  }) {
    return CycleHistoryDraft(
      currentCycleDay: currentCycleDay ?? this.currentCycleDay,
      rows: rows ?? this.rows,
    );
  }

  factory CycleHistoryDraft.fromPreset(CyclePreset preset) {
    final rows = <CycleHistoryRow>[];
    for (var i = 0; i < preset.cycleLengths.length + 1; i++) {
      rows.add(
        CycleHistoryRow(
          cycleLength: i == 0 ? null : preset.cycleLengths[i - 1],
          periodDuration: preset.periodDuration,
        ),
      );
    }
    return CycleHistoryDraft(
      currentCycleDay: preset.targetCycleDay,
      rows: rows,
    );
  }

  factory CycleHistoryDraft.fromPeriodLogs({
    required List<PeriodLog> logs,
    required DateTime simulatedToday,
  }) {
    if (logs.isEmpty) {
      return CycleHistoryDraft(
        currentCycleDay: 1,
        rows: [CycleHistoryRow()],
      );
    }

    final sorted = List<PeriodLog>.from(logs)
      ..sort((a, b) => a.startedOn.compareTo(b.startedOn));

    final rows = <CycleHistoryRow>[];
    for (var i = 0; i < sorted.length; i++) {
      final log = sorted[i];
      final periodDuration = log.endedOn == null
          ? CyclePreset.defaultPeriodDuration
          : dateOnly(log.endedOn!)
                  .difference(dateOnly(log.startedOn))
                  .inDays +
              1;
      int? length;
      if (i > 0) {
        length = dateOnly(log.startedOn)
            .difference(dateOnly(sorted[i - 1].startedOn))
            .inDays;
      }
      rows.add(
        CycleHistoryRow(
          cycleLength: length,
          periodDuration: periodDuration,
        ),
      );
    }

    final latest = sorted.last;
    final today = dateOnly(simulatedToday);
    final cycleDay =
        today.difference(dateOnly(latest.startedOn)).inDays + 1;

    return CycleHistoryDraft(
      currentCycleDay: cycleDay.clamp(1, 99),
      rows: rows,
    );
  }

  /// Computes calendar start dates for each row given [simulatedToday].
  List<DateTime> computedStarts(DateTime simulatedToday) {
    if (rows.isEmpty) return const [];

    final today = dateOnly(simulatedToday);
    var cursor = today.subtract(Duration(days: currentCycleDay - 1));
    final starts = List<DateTime>.filled(rows.length, cursor);

    for (var i = rows.length - 1; i >= 0; i--) {
      starts[i] = cursor;
      if (i > 0) {
        final length = rows[i].cycleLength ?? CyclePreset.defaultCycleLength;
        cursor = dateOnly(cursor).subtract(Duration(days: length));
      }
    }
    return starts;
  }

  /// Sets the period start for [index], keeping other starts fixed.
  ///
  /// Rebuilds cycle lengths (and [currentCycleDay] when the newest start moves)
  /// from the resulting start list. Returns [this] when the date would make
  /// starts non-increasing or place the latest start after [simulatedToday].
  CycleHistoryDraft withRowStartDate({
    required int index,
    required DateTime newStart,
    required DateTime simulatedToday,
  }) {
    if (index < 0 || index >= rows.length) return this;

    final today = dateOnly(simulatedToday);
    final starts = List<DateTime>.from(computedStarts(today));
    final start = dateOnly(newStart);
    starts[index] = start;

    for (var i = 0; i < starts.length - 1; i++) {
      if (!starts[i].isBefore(starts[i + 1])) return this;
    }
    if (starts.last.isAfter(today)) return this;

    final updated = <CycleHistoryRow>[
      for (var i = 0; i < rows.length; i++)
        CycleHistoryRow(
          cycleLength: i == 0
              ? null
              : starts[i].difference(starts[i - 1]).inDays,
          periodDuration: rows[i].periodDuration,
        ),
    ];

    final cycleDay = today.difference(starts.last).inDays + 1;
    return CycleHistoryDraft(
      currentCycleDay: cycleDay.clamp(1, 99),
      rows: updated,
    );
  }

  /// Inclusive date bounds for picking the period start of [index].
  ({DateTime firstDate, DateTime lastDate}) startDateBounds({
    required int index,
    required DateTime simulatedToday,
  }) {
    final today = dateOnly(simulatedToday);
    final starts = computedStarts(today);
    final firstDate = index == 0
        ? DateTime(today.year - 5)
        : starts[index - 1].add(const Duration(days: 1));
    final lastDate = index == starts.length - 1
        ? today
        : starts[index + 1].subtract(const Duration(days: 1));
    return (firstDate: firstDate, lastDate: lastDate);
  }

  CycleHistoryDraft addOldestRow() {
    if (rows.isEmpty) {
      return copyWith(rows: [CycleHistoryRow()]);
    }
    final updated = rows
        .map((row) => row.copyWith())
        .toList(growable: true);
    updated.insert(0, CycleHistoryRow(cycleLength: null));
    updated[1] = updated[1].copyWith(
      cycleLength: updated[1].cycleLength ?? CyclePreset.defaultCycleLength,
    );
    return copyWith(rows: updated);
  }

  CycleHistoryDraft removeOldestRow() {
    if (rows.length <= 1) {
      return copyWith(rows: [CycleHistoryRow()]);
    }
    final updated = rows
        .map((row) => row.copyWith())
        .toList(growable: true);
    updated.removeAt(0);
    updated[0] = updated[0].copyWith(cycleLength: null);
    return copyWith(rows: updated);
  }

  CycleHistoryDraft reorderRows(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return this;
    final updated = rows.map((row) => row.copyWith()).toList();
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(cycleLength: i == 0 ? null : updated[i].cycleLength ?? CyclePreset.defaultCycleLength);
    }
    return copyWith(rows: updated);
  }
}
