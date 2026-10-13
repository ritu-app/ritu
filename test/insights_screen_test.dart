import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle.dart';
import 'package:ritu/data/models/daily_log_entry.dart';
import 'package:ritu/data/models/period_log.dart';
import 'package:ritu/features/insights/insights_screen.dart';
import 'package:ritu/providers/cycle_snapshot_provider.dart';
import 'package:ritu/providers/daily_log_providers.dart';
import 'package:ritu/providers/period_providers.dart';
import 'package:ritu/providers/simulated_today_provider.dart';

void main() {
  final today = DateTime(2026, 9, 14);

  List<DailyLogEntry> logsFor(int days) {
    return [
      for (var day = 1; day <= days; day++)
        DailyLogEntry(
          id: day,
          loggedOn: DateTime(2026, 9, day),
          createdAt: today,
          updatedAt: today,
          wellbeing: day.isEven ? 8 : 2,
          energyLevel: day.isEven ? 'High' : 'Low',
          moods: [day.isEven ? 'Calm' : 'Anxious'],
          symptoms: day.isEven
              ? const ['Headache']
              : const ['Bloating', 'Acne'],
        ),
    ];
  }

  CycleSnapshot snapshotFor({
    CycleClassification classification = CycleClassification.unclassified,
    List<int> sample = const [],
    double? mean,
    int completedCycles = 0,
  }) {
    return CycleSnapshot(
      referenceDate: today,
      completedCycles: completedCycles,
      insightsMode: completedCycles >= 3
          ? InsightsMode.full
          : InsightsMode.partial,
      classification: classification,
      sample: sample,
      mean: mean,
    );
  }

  List<PeriodLog> periodsOn(List<DateTime> starts) {
    return [
      for (var i = 0; i < starts.length; i++)
        PeriodLog(
          id: i + 1,
          startedOn: starts[i],
          source: PeriodSources.calendar,
          createdAt: today,
          updatedAt: today,
        ),
    ];
  }

  Future<void> pumpInsights(
    WidgetTester tester, {
    required int loggedDays,
    int patternDaysRequired = 14,
    bool loggedToday = false,
    CycleSnapshot? snapshot,
    List<DateTime> periodStarts = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          totalLoggedDaysProvider.overrideWith(
            (ref) => Stream.value(loggedDays),
          ),
          allDailyLogsProvider.overrideWith(
            (ref) => Stream.value(logsFor(loggedDays)),
          ),
          todayLogProvider.overrideWith(
            (ref) => Stream.value(loggedToday ? logsFor(1).single : null),
          ),
          simulatedTodayProvider.overrideWithValue(today),
          cycleSnapshotProvider.overrideWithValue(
            AsyncData(snapshot ?? snapshotFor()),
          ),
          allPeriodsProvider.overrideWith(
            (ref) => Stream.value(periodsOn(periodStarts)),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: InsightsScreen(patternDaysRequired: patternDaysRequired),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('stays on the progress teaser before 14 logs', (tester) async {
    await pumpInsights(tester, loggedDays: 13);

    expect(find.text('Understand your patterns'), findsOneWidget);
    expect(find.text('Learning your rhythm'), findsOneWidget);
    expect(find.text('Wellbeing over time'), findsNothing);
    expect(find.text('Key insights'), findsNothing);
  });

  testWidgets(
    'shows history once 14 logs exist, with the note under Key insights',
    (tester) async {
      await pumpInsights(
        tester,
        loggedDays: 14,
        snapshot: snapshotFor(completedCycles: 3),
        periodStarts: [
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 6),
          DateTime(2026, 9, 11),
        ],
      );

      expect(find.text('Based on 3 cycles'), findsOneWidget);
      expect(find.text('Based on 14 days of logs'), findsNothing);
      expect(find.text('Wellbeing over time'), findsOneWidget);
      expect(find.text('Sep'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Okay'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Key insights'), findsOneWidget);
      expect(find.text('Consistency is powerful'), findsOneWidget);
      expect(find.text('Starting to notice something'), findsNothing);
      expect(find.text('What you’ll unlock'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Key insights')).dy,
        lessThan(tester.getTopLeft(find.text('Consistency is powerful')).dy),
      );

      await tester.tap(find.text('Mood'));
      await tester.pump();
      expect(find.text('Mood over time'), findsOneWidget);
      expect(find.text('Heavy'), findsOneWidget);
      expect(find.text('Mixed'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Most logged moods'), findsOneWidget);
      expect(find.text('Anxious'), findsOneWidget);
      expect(find.text('Calm'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Anxious')).dy,
        tester.getTopLeft(find.text('Calm')).dy,
      );
      final chip = find
          .ancestor(of: find.text('Anxious'), matching: find.byType(Container))
          .first;
      expect(
        tester.getSize(chip).width,
        lessThan(tester.getSize(find.byType(ListView)).width - 40),
      );
      expect(find.text('Key insights'), findsNothing);
      expect(find.text('Mood patterns'), findsNothing);

      await tester.tap(find.text('Energy'));
      await tester.pump();
      expect(find.text('Energy over time'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Energy levels you log most'), findsOneWidget);
      expect(find.text('Key insights'), findsNothing);
      expect(find.text('Energy patterns'), findsNothing);

      await tester.tap(find.text('Body'));
      await tester.pump();
      expect(find.text('Body signals over time'), findsOneWidget);
      expect(find.text('2 or more signals'), findsOneWidget);
      expect(find.text('one signal'), findsOneWidget);
      expect(find.text('No signal'), findsOneWidget);
      expect(find.text('Most common signals'), findsOneWidget);
      expect(find.text('Acne'), findsOneWidget);
      expect(find.text('Bloating'), findsOneWidget);
      expect(find.text('Headache'), findsOneWidget);
      expect(find.text('Key insights'), findsNothing);
      expect(find.text('Body signals patterns'), findsNothing);
    },
  );

  testWidgets('holds mood, energy, and body until three cycles exist', (
    tester,
  ) async {
    await pumpInsights(
      tester,
      loggedDays: 14,
      snapshot: snapshotFor(completedCycles: 6),
      periodStarts: [DateTime(2026, 8, 1)],
    );

    expect(find.text('Based on 14 days of logs'), findsOneWidget);
    expect(find.text('Wellbeing over time'), findsOneWidget);

    for (final tab in ['Mood', 'Energy', 'Body']) {
      await tester.tap(find.text(tab));
      await tester.pump();
      expect(find.text('Keep going'), findsOneWidget);
      expect(
        find.text(
          'You’re building something meaningful. '
          '2 more cycles to unlock deeper insights',
        ),
        findsOneWidget,
      );
      expect(find.text('Mood over time'), findsNothing);
      expect(find.text('Energy over time'), findsNothing);
      expect(find.text('Body signals over time'), findsNothing);
      expect(find.text('Key insights'), findsNothing);
    }

    await tester.tap(find.text('Overview'));
    await tester.pump();
    expect(find.text('Wellbeing over time'), findsOneWidget);
    expect(find.text('Keep going'), findsNothing);
  });

  testWidgets('replaces the consistency note once the cycle is regular', (
    tester,
  ) async {
    await pumpInsights(
      tester,
      loggedDays: 14,
      snapshot: snapshotFor(
        classification: CycleClassification.regular,
        sample: const [27, 28, 27],
        mean: 82 / 3,
        completedCycles: 3,
      ),
      periodStarts: [
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 6),
        DateTime(2026, 9, 11),
      ],
    );

    expect(find.text('Cycle length is consistent'), findsOneWidget);
    expect(
      find.text('Last 3 cycles: 27, 28, 27 days. Healthy stable variation'),
      findsOneWidget,
    );
    expect(find.text('Average 27.3 days'), findsOneWidget);
    expect(find.text('Consistency is powerful'), findsNothing);
    expect(find.text('Headaches cluster on days 2–3'), findsNothing);

    for (final tab in ['Mood', 'Energy', 'Body']) {
      await tester.tap(find.text(tab));
      await tester.pump();
      expect(find.text('Cycle length is consistent'), findsNothing);
      expect(find.text('Consistency is powerful'), findsNothing);
      expect(find.text('Keep going'), findsNothing);
      expect(find.text('Key insights'), findsNothing);
    }

    await tester.tap(find.text('Overview'));
    await tester.pump();
    expect(find.text('Cycle length is consistent'), findsOneWidget);
  });

  testWidgets(
    'shows the variable explanation on every tab and the range on overview',
    (tester) async {
      await pumpInsights(
        tester,
        loggedDays: 14,
        snapshot: snapshotFor(
          classification: CycleClassification.variable,
          sample: const [24, 28, 33],
          completedCycles: 3,
        ),
        periodStarts: [
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 6),
          DateTime(2026, 9, 11),
        ],
      );

      expect(find.text('How insights work for you'), findsOneWidget);
      expect(find.text('Cycle length varies - 24 to 33 days'), findsOneWidget);
      expect(find.text('3 cycles recorded'), findsOneWidget);
      expect(find.text('Consistency is powerful'), findsNothing);
      expect(find.text('Cycle length is consistent'), findsNothing);
      expect(find.text('Low energy 5–8 days before your period'), findsNothing);
      expect(find.text('Cycle length record'), findsNothing);
      expect(
        tester.getTopLeft(find.text('How insights work for you')).dy,
        lessThan(tester.getTopLeft(find.text('Wellbeing over time')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Key insights')).dy,
        lessThan(
          tester
              .getTopLeft(find.text('Cycle length varies - 24 to 33 days'))
              .dy,
        ),
      );

      for (final tab in [
        ('Mood', 'Mood over time'),
        ('Energy', 'Energy over time'),
        ('Body', 'Body signals over time'),
      ]) {
        await tester.tap(find.text(tab.$1));
        await tester.pump();
        expect(find.text('How insights work for you'), findsOneWidget);
        expect(find.text('Cycle length varies - 24 to 33 days'), findsNothing);
        expect(find.text('Key insights'), findsNothing);
        expect(
          tester.getTopLeft(find.text('How insights work for you')).dy,
          lessThan(tester.getTopLeft(find.text(tab.$2)).dy),
        );
      }
    },
  );

  testWidgets(
    'shows unpredictable banners on every tab and the record on overview',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpInsights(
        tester,
        loggedDays: 14,
        snapshot: snapshotFor(
          classification: CycleClassification.unpredictable,
          sample: const [4, 4, 3],
          completedCycles: 3,
        ),
        periodStarts: [
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 5),
          DateTime(2026, 9, 9),
          DateTime(2026, 9, 12),
        ],
      );

      expect(find.text('How insights work for you'), findsOneWidget);
      expect(
        find.text(
          'Your cycles vary quite a bit (3–4 days). '
          "Phase strips aren't shown. Patterns here are based on what "
          "you've logged, not cycle timing.",
        ),
        findsOneWidget,
      );
      expect(
        find.text('Cycles vary significantly - 3 to 4 days'),
        findsOneWidget,
      );
      expect(find.text('3 cycles recorded'), findsOneWidget);
      expect(find.text('Cycle length record'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Key insights')).dy,
        lessThan(tester.getTopLeft(find.text('Cycle length record')).dy),
      );
      expect(find.text('Sep → Sep 2026'), findsNWidgets(3));
      expect(find.text('4 days'), findsNWidgets(2));
      expect(find.text('3 days'), findsOneWidget);
      expect(find.text('Sep 2026 → ongoing'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(
        find.text('This table is included in your doctor PDF report'),
        findsOneWidget,
      );
      expect(find.text('Consistency is powerful'), findsNothing);
      expect(find.text('Cycle length varies - 24 to 33 days'), findsNothing);
      expect(find.text('Mood improves after your period ends'), findsNothing);

      for (final tab in ['Mood', 'Energy', 'Body']) {
        await tester.tap(find.text(tab));
        await tester.pump();
        expect(find.text('How insights work for you'), findsOneWidget);
        expect(
          find.text('Cycles vary significantly - 3 to 4 days'),
          findsNothing,
        );
        expect(find.text('Cycle length record'), findsNothing);
        expect(find.text('Key insights'), findsNothing);
      }
    },
  );

  testWidgets('uses the singular day label for a one-day threshold', (
    tester,
  ) async {
    await pumpInsights(tester, loggedDays: 1, patternDaysRequired: 1);
    expect(find.text('Based on 1 day of logs'), findsOneWidget);
  });
}
