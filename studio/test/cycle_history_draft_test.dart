import 'package:flutter_test/flutter_test.dart';
import 'package:ritu_studio/models/cycle_history_draft.dart';
import 'package:ritu_studio/presets/cycle_presets.dart';

void main() {
  final today = DateTime(2026, 10, 28);

  group('withRowStartDate', () {
    test('moving newest start updates current cycle day', () {
      final draft = CycleHistoryDraft.fromPreset(CyclePreset.partial1);
      final starts = draft.computedStarts(today);
      final newest = starts.last;

      final updated = draft.withRowStartDate(
        index: starts.length - 1,
        newStart: newest.subtract(const Duration(days: 3)),
        simulatedToday: today,
      );

      expect(updated.currentCycleDay, draft.currentCycleDay + 3);
      expect(
        updated.computedStarts(today).last,
        newest.subtract(const Duration(days: 3)),
      );
    });

    test('moving an older start keeps other starts and rebuilds length', () {
      final draft = CycleHistoryDraft(
        currentCycleDay: 12,
        rows: [
          CycleHistoryRow(),
          CycleHistoryRow(cycleLength: 30),
          CycleHistoryRow(cycleLength: 28),
        ],
      );
      final before = draft.computedStarts(today);
      final newOldest = before[0].add(const Duration(days: 2));

      final updated = draft.withRowStartDate(
        index: 0,
        newStart: newOldest,
        simulatedToday: today,
      );
      final after = updated.computedStarts(today);

      expect(after[0], newOldest);
      expect(after[1], before[1]);
      expect(after[2], before[2]);
      expect(updated.rows[1].cycleLength, after[1].difference(after[0]).inDays);
      expect(updated.currentCycleDay, draft.currentCycleDay);
    });

    test('rejects start that would invert order', () {
      final draft = CycleHistoryDraft.fromPreset(CyclePreset.partial2);
      final starts = draft.computedStarts(today);

      final updated = draft.withRowStartDate(
        index: 0,
        newStart: starts[1],
        simulatedToday: today,
      );

      expect(updated.computedStarts(today), starts);
      expect(updated.currentCycleDay, draft.currentCycleDay);
    });
  });

  group('startDateBounds', () {
    test('newest row cannot start after simulated today', () {
      final draft = CycleHistoryDraft.fromPreset(CyclePreset.partial1);
      final bounds = draft.startDateBounds(
        index: draft.rows.length - 1,
        simulatedToday: today,
      );
      expect(bounds.lastDate, today);
    });
  });
}
