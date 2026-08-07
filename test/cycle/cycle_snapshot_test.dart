import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle.dart';
import 'package:ritu/core/cycle/cycle_adapters.dart';
import 'package:ritu/data/models/period_log.dart';

void main() {
  group('computeCycleSnapshot', () {
    final regularHistory = [
      PeriodLog(
        id: 7,
        startedOn: DateTime(2026, 3, 1),
        endedOn: DateTime(2026, 3, 5),
        source: 'test',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      ),
      PeriodLog(
        id: 6,
        startedOn: DateTime(2026, 2, 1),
        endedOn: DateTime(2026, 2, 5),
        source: 'test',
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 1),
      ),
      PeriodLog(
        id: 5,
        startedOn: DateTime(2026, 1, 4),
        endedOn: DateTime(2026, 1, 8),
        source: 'test',
        createdAt: DateTime(2026, 1, 4),
        updatedAt: DateTime(2026, 1, 4),
      ),
      PeriodLog(
        id: 4,
        startedOn: DateTime(2025, 12, 7),
        endedOn: DateTime(2025, 12, 11),
        source: 'test',
        createdAt: DateTime(2025, 12, 7),
        updatedAt: DateTime(2025, 12, 7),
      ),
    ];

    test('partial insights with fewer than 3 completed cycles', () {
      final logs = regularHistory.take(3).toList();
      final snapshot = cycleSnapshotFromPeriodLogs(
        referenceDate: DateTime(2026, 3, 10),
        logs: logs,
      );
      expect(snapshot.insightsMode, InsightsMode.partial);
      expect(snapshot.showsPhaseEstimates, isFalse);
    });

    test('regular user on follicular day shows phase estimate', () {
      // Extend to 4 starts → 3 completed cycles (minimum for full insights).
      final logs = [
        PeriodLog(
          id: 8,
          startedOn: DateTime(2026, 4, 1),
          endedOn: DateTime(2026, 4, 5),
          source: 'test',
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime(2026, 4, 1),
        ),
        ...regularHistory,
      ];
      final snapshot = cycleSnapshotFromPeriodLogs(
        referenceDate: DateTime(2026, 4, 10),
        logs: logs,
      );
      expect(snapshot.insightsMode, InsightsMode.full);
      expect(snapshot.classification, CycleClassification.regular);
      expect(snapshot.cycleDay, 10);
      expect(snapshot.todayPhase, CyclePhase.follicular);
      expect(snapshot.phaseConfidence, PhaseConfidence.exact);
      expect(snapshot.showsPhaseEstimates, isTrue);
    });

    test('bleed day always logged menstrual regardless of classification', () {
      final logs = [
        PeriodLog(
          id: 1,
          startedOn: DateTime(2026, 4, 1),
          endedOn: DateTime(2026, 4, 5),
          source: 'test',
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime(2026, 4, 1),
        ),
      ];
      final snapshot = cycleSnapshotFromPeriodLogs(
        referenceDate: DateTime(2026, 4, 3),
        logs: logs,
      );
      expect(snapshot.todayPhase, CyclePhase.menstrual);
      expect(snapshot.phaseConfidence, PhaseConfidence.logged);
      expect(snapshot.ranges, isNull);
    });
  });
}
