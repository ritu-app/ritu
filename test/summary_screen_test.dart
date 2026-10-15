import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/features/summary/summary_screen.dart';
import 'package:ritu/theme/ritu_theme.dart';

void main() {
  Future<void> pumpSummary(
    WidgetTester tester, {
    required int loggedDays,
    int completedCycles = 0,
    int patternDaysRequired = 14,
    VoidCallback? onGenerateSummary,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildRituTheme(),
        home: Scaffold(
          body: SummaryScreen(
            loggedDaysCount: loggedDays,
            patternDaysRequired: patternDaysRequired,
            completedCycles: completedCycles,
            onGenerateSummary: onGenerateSummary,
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
        'Bring together your logs and cycle into one meaningful summary',
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
    var taps = 0;
    await pumpSummary(
      tester,
      loggedDays: 20,
      completedCycles: 1,
      onGenerateSummary: () => taps++,
    );

    expect(find.text('Still early days'), findsNothing);
    expect(find.text('Generate summary'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Generate summary')).dy,
      lessThan(tester.getTopLeft(find.text('Why summary valuable')).dy),
    );

    await tester.tap(find.text('Generate summary'));
    expect(taps, 1);
  });
}
