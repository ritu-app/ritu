import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/data/models/daily_log_entry.dart';
import 'package:ritu/features/insights/insights_screen.dart';
import 'package:ritu/providers/daily_log_providers.dart';
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

  Future<void> pumpInsights(
    WidgetTester tester, {
    required int loggedDays,
    int patternDaysRequired = 14,
    bool loggedToday = false,
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

  testWidgets('shows history once 14 logs exist and skips key insights', (
    tester,
  ) async {
    await pumpInsights(tester, loggedDays: 14);

    expect(find.text('Based on 14 days of logs'), findsOneWidget);
    expect(find.text('Wellbeing over time'), findsOneWidget);
    expect(find.text('Sep'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Okay'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('No data'), findsOneWidget);
    expect(find.text('Consistency is powerful'), findsOneWidget);
    expect(find.text('Key insights'), findsNothing);
    expect(find.text('What you’ll unlock'), findsNothing);

    await tester.tap(find.text('Mood'));
    await tester.pump();
    expect(find.text('Mood over time'), findsOneWidget);
    expect(find.text('Heavy'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);

    await tester.tap(find.text('Energy'));
    await tester.pump();
    expect(find.text('Energy over time'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);

    await tester.tap(find.text('Body'));
    await tester.pump();
    expect(find.text('Body signals over time'), findsOneWidget);
    expect(find.text('2 or more signals'), findsOneWidget);
    expect(find.text('one signal'), findsOneWidget);
    expect(find.text('No signal'), findsOneWidget);
    expect(find.text('Key insights'), findsNothing);
  });

  testWidgets('uses the singular day label for a one-day threshold', (
    tester,
  ) async {
    await pumpInsights(tester, loggedDays: 1, patternDaysRequired: 1);
    expect(find.text('Based on 1 day of logs'), findsOneWidget);
  });
}
