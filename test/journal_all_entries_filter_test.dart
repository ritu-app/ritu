import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/data/models/journal_entry.dart';
import 'package:ritu/features/journal/journal_all_entries_screen.dart';
import 'package:ritu/providers/journal_entry_providers.dart';
import 'package:ritu/providers/period_providers.dart';
import 'package:ritu/providers/simulated_today_provider.dart';
import 'package:ritu/theme/ritu_theme.dart';

void main() {
  final today = DateTime(2026, 8, 20);
  final entries = [
    _entry(
      id: 1,
      loggedOn: DateTime(2026, 8, 10),
      body: 'Felt more energetic today.',
    ),
    _entry(id: 2, loggedOn: DateTime(2026, 8, 5), body: 'A quiet morning.'),
  ];

  Future<void> pumpEntries(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          simulatedTodayProvider.overrideWithValue(today),
          pastJournalEntriesProvider.overrideWith(
            (ref) => Stream.value(entries),
          ),
          allPeriodsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          theme: buildRituTheme(),
          home: const Scaffold(body: JournalAllEntriesScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a time range stays visible and search can miss inside it', (
    tester,
  ) async {
    await pumpEntries(tester);

    await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();

    expect(find.text('Last month'), findsOneWidget);
    expect(find.text('2 entries'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'energetic');
    await tester.pump();

    expect(find.text('energetic'), findsWidgets);
    expect(find.text('1 entry'), findsOneWidget);
    expect(find.text('A quiet morning.'), findsNothing);

    await tester.enterText(find.byType(TextField), 'migraine');
    await tester.pump();

    expect(find.textContaining('No entries matching'), findsOneWidget);
    expect(find.textContaining('"migraine"'), findsOneWidget);
    expect(find.textContaining('Last month'), findsWidgets);
    expect(find.text('Clear filter'), findsOneWidget);

    await tester.tap(find.text('Clear filter'));
    await tester.pump();

    expect(find.text('Clear filter'), findsNothing);
    expect(find.text('No matching entries'), findsOneWidget);
  });

  testWidgets('a chosen day shows its entry or an empty date', (tester) async {
    await pumpEntries(tester);

    await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calender'));
    await tester.pumpAndSettle();

    expect(find.text('Calender'), findsWidgets);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    expect(find.text('Aug 10, 2026'), findsOneWidget);
    expect(find.text('Search entries'), findsNothing);
    expect(find.text('August 2026'), findsNothing);
    expect(find.textContaining('Felt more energetic today.'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pump();

    expect(find.text('Search entries'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calender'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(find.text('Aug 3, 2026'), findsOneWidget);
    expect(find.textContaining('No entry on'), findsOneWidget);
    expect(find.textContaining('August 3, 2026'), findsOneWidget);
    expect(
      find.text('Pick another date, or clear to see your full history'),
      findsOneWidget,
    );
  });
}

JournalEntry _entry({
  required int id,
  required DateTime loggedOn,
  required String body,
}) {
  return JournalEntry(
    id: id,
    loggedOn: loggedOn,
    body: body,
    createdAt: loggedOn,
    updatedAt: loggedOn,
  );
}
