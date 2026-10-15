import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/features/summary/summary_screen.dart';
import 'package:ritu/providers/journal_entry_providers.dart';
import 'package:ritu/providers/period_providers.dart';
import 'package:ritu/providers/simulated_today_provider.dart';
import 'package:ritu/theme/ritu_theme.dart';

void main() {
  Future<void> pumpSummary(
    WidgetTester tester, {
    required int loggedDays,
    int completedCycles = 0,
    int patternDaysRequired = 14,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          simulatedTodayProvider.overrideWithValue(DateTime(2026, 8, 20)),
          allJournalEntriesProvider.overrideWith(
            (ref) => Stream.value(const []),
          ),
          allPeriodsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          theme: buildRituTheme(),
          home: Scaffold(
            body: SummaryScreen(
              loggedDaysCount: loggedDays,
              patternDaysRequired: patternDaysRequired,
              completedCycles: completedCycles,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('keeps the teaser before 14 logs', (tester) async {
    await pumpSummary(tester, loggedDays: 13);

    expect(find.text('Your first summary is on the way'), findsOneWidget);
    expect(find.text('13 of 14 days – summary unlock at 14'), findsOneWidget);
    expect(find.text('Generate summary'), findsNothing);
    expect(find.text('Still early days'), findsNothing);
  });

  testWidgets('shows the early-days note once 14 days are logged', (
    tester,
  ) async {
    await pumpSummary(tester, loggedDays: 14);

    expect(find.text('Your first summary is on the way'), findsNothing);
    expect(
      find.text(
        'Bring together your journal, mood, sleep, body signals '
        'and cycle into one meaningful summary',
      ),
      findsOneWidget,
    );
    expect(find.text('Still early days'), findsOneWidget);
    expect(find.text('Generate summary'), findsOneWidget);
    expect(find.text('Why summary valuable'), findsOneWidget);

    expect(tester.getSize(find.byType(Image)).height, 320);
    expect(
      tester.getTopLeft(find.text('Still early days')).dy,
      lessThan(tester.getTopLeft(find.text('Generate summary')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Generate summary')).dy,
      lessThan(tester.getTopLeft(find.text('Why summary valuable')).dy),
    );
  });

  testWidgets('drops the early-days note after a completed cycle', (
    tester,
  ) async {
    await pumpSummary(tester, loggedDays: 20, completedCycles: 1);

    expect(find.text('Still early days'), findsNothing);
    expect(find.text('Generate summary'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Generate summary')).dy,
      lessThan(tester.getTopLeft(find.text('Why summary valuable')).dy),
    );

    await tester.tap(find.text('Generate summary'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Choose what to include in your summary'), findsOneWidget);
    expect(find.text('Generate PDF'), findsOneWidget);
  });
}
