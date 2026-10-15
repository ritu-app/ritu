import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/data/models/journal_entry.dart';
import 'package:ritu/features/summary/generate_summary_sheet.dart';
import 'package:ritu/providers/daily_log_providers.dart';
import 'package:ritu/providers/journal_entry_providers.dart';
import 'package:ritu/providers/period_providers.dart';
import 'package:ritu/providers/simulated_today_provider.dart';
import 'package:ritu/theme/ritu_colors.dart';
import 'package:ritu/theme/ritu_theme.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    required DateTime today,
    List<JournalEntry> entries = const [],
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          simulatedTodayProvider.overrideWithValue(today),
          allJournalEntriesProvider.overrideWith(
            (ref) => Stream.value(entries),
          ),
          allPeriodsProvider.overrideWith((ref) => Stream.value(const [])),
          allDailyLogsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          theme: buildRituTheme(),
          home: const Scaffold(body: _OpenSheet()),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder row(String label) {
    return find.ancestor(of: find.text(label), matching: find.byType(InkWell));
  }

  void expectChecked(WidgetTester tester, String label, bool checked) {
    expect(
      find.descendant(
        of: row(label),
        matching: find.byIcon(LucideIcons.circleCheck),
      ),
      checked ? findsOneWidget : findsNothing,
    );
  }

  void expectRadioSelected(String label, bool selected) {
    expect(
      find.descendant(
        of: row(label),
        matching: find.byWidgetPredicate((widget) {
          final decoration = widget is Container ? widget.decoration : null;
          return decoration is BoxDecoration &&
              decoration.color == RituColors.fillBrandPressed;
        }),
      ),
      selected ? findsOneWidget : findsNothing,
    );
  }

  testWidgets('opens on the last 3 months with the default includes', (
    tester,
  ) async {
    await pumpSheet(tester, today: DateTime(2026, 8, 20));

    expect(find.text('Generate summary'), findsOneWidget);
    expect(find.text('Choose what to include in your summary'), findsOneWidget);
    expectRadioSelected('Last 3 months', true);
    expectRadioSelected('Custom', false);

    expectChecked(tester, 'Cycle length', true);
    expectChecked(tester, 'Mood patterns', false);
    expectChecked(tester, 'Energy patterns', false);
    expectChecked(tester, 'Body signals', false);
    expectChecked(tester, 'Sleep logs', true);
    expectChecked(tester, 'Wellbeing score', true);
    expectChecked(tester, 'Journal entries', true);
    expect(find.text('Tap to choose which ones'), findsOneWidget);
    expect(find.text('Generate PDF'), findsOneWidget);
  });

  testWidgets('custom range stays closed until both dates are confirmed', (
    tester,
  ) async {
    await pumpSheet(tester, today: DateTime(2026, 8, 20));

    await tester.tap(find.text('Custom'));
    await tester.pump();

    expect(find.text('Select date range'), findsOneWidget);
    expect(find.text('Select date'), findsNWidgets(2));
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm range'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('10'));
    await tester.pump();
    expect(find.text('Aug 10, 2026'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm range'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('17'));
    await tester.pump();
    expect(find.text('Aug 17, 2026'), findsOneWidget);

    await tester.ensureVisible(find.text('Confirm range'));
    await tester.pump();
    await tester.tap(find.text('Confirm range'));
    await tester.pump();

    expect(find.text('Select date range'), findsNothing);
    expectRadioSelected('Custom', true);
    expectRadioSelected('Last 3 months', false);
  });

  testWidgets('leaving the date page keeps the previous range', (tester) async {
    await pumpSheet(tester, today: DateTime(2026, 8, 20));

    await tester.tap(find.text('Custom'));
    await tester.pump();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == LucideIcons.chevronLeft &&
            widget.size == 24,
      ),
    );
    await tester.pump();

    expect(find.text('Select date range'), findsNothing);
    expectRadioSelected('Last 3 months', true);
    expectRadioSelected('Custom', false);
  });

  testWidgets('journal picker adds entries from the selected range', (
    tester,
  ) async {
    final today = DateTime(2026, 9, 15);
    await pumpSheet(
      tester,
      today: today,
      entries: [
        JournalEntry(
          id: 1,
          loggedOn: DateTime(2026, 7, 17),
          body: 'July riverside walk',
          createdAt: today,
          updatedAt: today,
        ),
        JournalEntry(
          id: 2,
          loggedOn: DateTime(2026, 1, 4),
          body: 'January note',
          createdAt: today,
          updatedAt: today,
        ),
      ],
    );

    await tester.ensureVisible(find.text('Journal entries'));
    await tester.tap(find.text('Journal entries'));
    await tester.pump();

    expect(find.text('Showing entries from the last 3 months'), findsOneWidget);
    expect(find.text('July riverside walk'), findsOneWidget);
    expect(find.text('January note'), findsNothing);
    expect(find.text('July 2026'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Add 0 entries'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('July riverside walk'));
    await tester.pump();
    expect(find.text('Add 1 entry'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pump();
    expect(find.text('Tap to choose which ones'), findsOneWidget);

    await tester.ensureVisible(find.text('Journal entries'));
    await tester.tap(find.text('Journal entries'));
    await tester.pump();
    await tester.tap(find.text('July riverside walk'));
    await tester.pump();
    await tester.tap(find.text('Add 1 entry'));
    await tester.pump();

    expect(find.text('1 entry selected · Tap to edit'), findsOneWidget);
    expectChecked(tester, 'Journal entries', true);
  });
}

class _OpenSheet extends StatelessWidget {
  const _OpenSheet();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => showGenerateSummarySheet(context),
        child: const Text('Open'),
      ),
    );
  }
}
