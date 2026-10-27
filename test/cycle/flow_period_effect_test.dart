import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle.dart';

void main() {
  final today = DateTime(2026, 4, 20);

  FlowPeriodSnapshot period({
    required DateTime startedOn,
    DateTime? endedOn,
    bool endConfirmed = false,
    bool startedFromDailyLog = false,
  }) {
    return FlowPeriodSnapshot(
      startedOn: startedOn,
      endedOn: endedOn,
      endConfirmed: endConfirmed,
      startedFromDailyLog: startedFromDailyLog,
    );
  }

  group('effectForFlowLog', () {
    test('bleeding with no history starts a logged period', () {
      final effect = effectForFlowLog(
        loggedOn: today,
        flowIntensity: 'Spotting',
        periods: const [],
      );

      expect(effect, isA<StartLoggedPeriod>());
      final start = effect as StartLoggedPeriod;
      expect(start.startedOn, today);
      expect(start.endedOn, DateTime(2026, 4, 24));
    });

    test('uses the profile period length for the assumed end', () {
      final effect = effectForFlowLog(
        loggedOn: today,
        flowIntensity: 'Heavy',
        periods: const [],
        typicalPeriodDays: 7,
      );

      expect((effect as StartLoggedPeriod).endedOn, DateTime(2026, 4, 26));
    });

    test('None and a skipped flow do not start a period', () {
      expect(
        effectForFlowLog(
          loggedOn: today,
          flowIntensity: 'None',
          periods: const [],
        ),
        isA<NoFlowPeriodEffect>(),
      );
      expect(
        effectForFlowLog(
          loggedOn: today,
          flowIntensity: null,
          periods: const [],
        ),
        isA<NoFlowPeriodEffect>(),
      );
    });

    test('flow after the period has ended starts menstrual day 1', () {
      final history = [
        period(startedOn: DateTime(2026, 1, 7), endedOn: DateTime(2026, 1, 11)),
        period(startedOn: DateTime(2026, 2, 4), endedOn: DateTime(2026, 2, 8)),
        period(startedOn: DateTime(2026, 3, 4), endedOn: DateTime(2026, 3, 8)),
        period(startedOn: DateTime(2026, 4, 1), endedOn: DateTime(2026, 4, 5)),
      ];

      final before = computeCycleSnapshot(
        referenceDate: today,
        episodes: [
          for (final episode in history)
            PeriodEpisode(
              startedOn: episode.startedOn,
              endedOn: episode.endedOn,
            ),
        ],
      );
      expect(before.cycleDay, 20);
      expect(before.todayPhase, CyclePhase.luteal);

      final effect = effectForFlowLog(
        loggedOn: today,
        flowIntensity: 'Medium',
        periods: history,
      );
      expect(effect, isA<StartLoggedPeriod>());
      final start = effect as StartLoggedPeriod;

      final after = computeCycleSnapshot(
        referenceDate: today,
        episodes: [
          for (final episode in history)
            PeriodEpisode(
              startedOn: episode.startedOn,
              endedOn: episode.endedOn,
            ),
          PeriodEpisode(startedOn: start.startedOn, endedOn: start.endedOn),
        ],
      );
      expect(after.cycleDay, 1);
      expect(after.todayPhase, CyclePhase.menstrual);
      expect(after.phaseConfidence, PhaseConfidence.logged);
    });

    test('flow inside 10 days extends the same episode', () {
      final current = period(
        startedOn: DateTime(2026, 4, 14),
        endedOn: DateTime(2026, 4, 18),
      );
      final effect = effectForFlowLog(
        loggedOn: DateTime(2026, 4, 20),
        flowIntensity: 'Light',
        periods: [current],
      );

      expect(effect, isA<ExtendPeriodThrough>());
      final extend = effect as ExtendPeriodThrough;
      expect(extend.startedOn, DateTime(2026, 4, 14));
      expect(extend.endedOn, DateTime(2026, 4, 20));

      final snapshot = computeCycleSnapshot(
        referenceDate: DateTime(2026, 4, 20),
        episodes: [
          PeriodEpisode(startedOn: extend.startedOn, endedOn: extend.endedOn),
        ],
      );
      expect(snapshot.cycleDay, 7);
      expect(snapshot.todayPhase, CyclePhase.menstrual);
    });

    test('day 10 still continues the episode and day 11 starts a new one', () {
      final current = period(
        startedOn: DateTime(2026, 4, 1),
        endedOn: DateTime(2026, 4, 5),
      );

      final day10 = effectForFlowLog(
        loggedOn: DateTime(2026, 4, 10),
        flowIntensity: 'Spotting',
        periods: [current],
      );
      expect(day10, isA<ExtendPeriodThrough>());

      final day11 = effectForFlowLog(
        loggedOn: DateTime(2026, 4, 11),
        flowIntensity: 'Spotting',
        periods: [current],
      );
      expect((day11 as StartLoggedPeriod).startedOn, DateTime(2026, 4, 11));
    });

    test('a confirmed end starts a new period even inside 10 days', () {
      final effect = effectForFlowLog(
        loggedOn: DateTime(2026, 4, 8),
        flowIntensity: 'Medium',
        periods: [
          period(
            startedOn: DateTime(2026, 4, 4),
            endedOn: DateTime(2026, 4, 6),
            endConfirmed: true,
          ),
        ],
      );

      expect((effect as StartLoggedPeriod).startedOn, DateTime(2026, 4, 8));
    });

    test('flow on a day that is already bleeding does nothing', () {
      final effect = effectForFlowLog(
        loggedOn: DateTime(2026, 4, 3),
        flowIntensity: 'Heavy',
        periods: [
          period(
            startedOn: DateTime(2026, 4, 1),
            endedOn: DateTime(2026, 4, 5),
          ),
        ],
      );
      expect(effect, isA<NoFlowPeriodEffect>());
    });

    test('an open period is already menstrual', () {
      final effect = effectForFlowLog(
        loggedOn: today,
        flowIntensity: 'Light',
        periods: [period(startedOn: DateTime(2026, 4, 18))],
      );
      expect(effect, isA<NoFlowPeriodEffect>());
    });

    test('clearing the flow that opened today removes that episode', () {
      final effect = effectForFlowLog(
        loggedOn: today,
        flowIntensity: 'None',
        periods: [
          period(
            startedOn: today,
            endedOn: DateTime(2026, 4, 24),
            startedFromDailyLog: true,
          ),
        ],
      );
      expect(effect, isA<RemoveLoggedPeriodStart>());
      expect((effect as RemoveLoggedPeriodStart).startedOn, today);
    });

    test('None does not delete a period that was not opened by this log', () {
      final effect = effectForFlowLog(
        loggedOn: today,
        flowIntensity: 'None',
        periods: [period(startedOn: today, endedOn: DateTime(2026, 4, 24))],
      );
      expect(effect, isA<NoFlowPeriodEffect>());
    });
  });
}
