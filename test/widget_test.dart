import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:ritu/app/ritu_app.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/backup/restore_backup_file.dart';
import 'package:ritu/data/backup/ritu_backup.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/models/profile.dart';
import 'package:ritu/data/repositories/drift/drift_daily_log_repository.dart';
import 'package:ritu/data/repositories/drift/drift_journal_entry_repository.dart';
import 'package:ritu/data/repositories/drift/drift_period_repository.dart';
import 'package:ritu/data/repositories/drift/drift_profile_repository.dart';
import 'package:ritu/data/repositories/drift/drift_symptom_repository.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/features/log/daily_log_flow.dart';
import 'package:ritu/features/setup/widgets/choice_chips.dart';
import 'package:ritu/providers/repository_providers.dart';
import 'package:ritu/theme/ritu_colors.dart';

/// Widget tests that mount [createRituApp] must unmount before the test ends
/// so Drift stream subscriptions can cancel without leaving pending timers.
void rituTestWidgets(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
    }
  });
}

class _RecordingUrlLauncher extends UrlLauncherPlatform {
  String? launched;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched = url;
    return true;
  }
}

Future<void> _logCycleLengths(
  DriftPeriodRepository periods,
  List<int> lengthsOldestFirst,
) async {
  final today = dateOnly(DateTime.now());
  var cursor = today;
  final starts = <DateTime>[today];
  for (final length in lengthsOldestFirst.reversed) {
    cursor = cursor.subtract(Duration(days: length));
    starts.add(cursor);
  }
  for (final startedOn in starts) {
    await periods.upsertPeriod(
      startedOn: startedOn,
      endedOn: startedOn.add(const Duration(days: 4)),
      source: PeriodSources.onboardingLast,
    );
  }
}

void main() {
  late AppDatabase database;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  rituTestWidgets('Splash screen shows Ritu branding and CTA', (tester) async {
    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Ritu'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Restore from backup'), findsOneWidget);
  });

  rituTestWidgets('Onboarding completes into homepage and persists name', (
    tester,
  ) async {
    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    // The confirmation screen's waving hand loops forever, so pumpAndSettle
    // would never see a settled frame — pump just enough for the route
    // transition to finish instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Hi, Maya'), findsOneWidget);
    expect(find.text('👋'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('4-5 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4-5 days'));
    await tester.pump();
    await tester.tap(find.text('This looks right'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip – I’ll build from today'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Maya ✨'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    final profile = await DriftProfileRepository(database).getProfile();
    expect(profile?.displayName, 'Maya');
    expect(profile?.hasCompletedOnboarding, isTrue);

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Maya'), findsOneWidget);
    expect(
      find.text(
        'Logging since ${formatDisplayDate(profile!.onboardingCompletedAt!)}',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(LucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Understand your patterns'), findsOneWidget);

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('Your space to reflect'), findsOneWidget);

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Export your health data'), findsOneWidget);

    final periods = DriftPeriodRepository(database);
    expect(await periods.getLatest(), isNotNull);
  });

  rituTestWidgets('Last period and past dates are stored from setup', (
    tester,
  ) async {
    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    // The confirmation screen's waving hand loops forever, so pumpAndSettle
    // would never see a settled frame — pump just enough for the route
    // transition to finish instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text("It's ended"), 120);
    await tester.tap(find.text("It's ended"));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Not sure - roughly'), 120);
    await tester.tap(find.text('Not sure - roughly'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('4-5 days'), 120);
    await tester.tap(find.text('4-5 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This looks right'));
    await tester.pumpAndSettle();

    final periods = DriftPeriodRepository(database);
    final latest = await periods.getLatest();
    expect(latest, isNotNull);
    expect(latest!.source, PeriodSources.onboardingLast);
    expect(latest.endStatus, PeriodEndStatus.rough);
    expect(latest.roughDurationBucket, RoughDurationBuckets.fourToFiveDays);

    final profiles = DriftProfileRepository(database);
    expect((await profiles.getProfile())?.typicalPeriodDays, 5);

    await tester.tap(find.text('Skip – I’ll build from today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('days into your cycle'), findsOneWidget);
    expect(find.text('No history yet'), findsOneWidget);
  });

  rituTestWidgets('Returning user skips onboarding when profile is complete', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsNothing);
    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Maya ✨'), findsOneWidget);
  });

  Future<void> seedRegularHistory() async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.setTypicalPeriodDays(5);
    await profiles.markOnboardingCompleted();

    // 4 starts → 3 completed cycles of length 28 → Regular.
    final starts = [
      DateTime(2026, 1, 7),
      DateTime(2026, 2, 4),
      DateTime(2026, 3, 4),
      DateTime(2026, 4, 1),
    ];
    for (final start in starts) {
      await periods.upsertPeriod(
        startedOn: start,
        endedOn: start.add(const Duration(days: 4)),
        source: PeriodSources.settings,
      );
    }
  }

  rituTestWidgets('Regular user in ovulatory phase sees golden header', (
    tester,
  ) async {
    await seedRegularHistory();

    await tester.pumpWidget(
      createRituApp(database: database, simulatedToday: DateTime(2026, 4, 14)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ovulatory phase'), findsOneWidget);
    expect(find.text('days into your cycle'), findsOneWidget);
    expect(find.text('Last period Apr 1'), findsOneWidget);
    expect(find.text('Next period Apr 29'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/phase_ovulatory.png')),
      findsOneWidget,
    );
  });

  rituTestWidgets('Regular user in menstrual phase sees rose header', (
    tester,
  ) async {
    await seedRegularHistory();

    await tester.pumpWidget(
      createRituApp(database: database, simulatedToday: DateTime(2026, 4, 3)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menstrual phase'), findsOneWidget);
    expect(find.text('days into your period'), findsOneWidget);
    expect(find.text('28 day cycle'), findsOneWidget);
    expect(find.text('Next period Apr 29'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/phase_menstrual.png')),
      findsOneWidget,
    );
  });

  rituTestWidgets('Regular user in luteal phase sees lilac header', (
    tester,
  ) async {
    await seedRegularHistory();

    await tester.pumpWidget(
      createRituApp(database: database, simulatedToday: DateTime(2026, 4, 26)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Luteal phase'), findsOneWidget);
    expect(find.text('days into your cycle'), findsOneWidget);
    expect(find.text('Last period Apr 1'), findsOneWidget);
    expect(find.text('Next period Apr 29'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/phase_luteal.png')),
      findsOneWidget,
    );
  });

  Future<void> seedVariableHistory() async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.setTypicalPeriodDays(5);
    await profiles.markOnboardingCompleted();

    // Spec Variable sample [21, 35, 23, 33, 25, 31] → 7 starts.
    // Midpoint C = 28; day 9 is follicular.
    const lengths = [21, 35, 23, 33, 25, 31];
    var cursor = DateTime(2025, 6, 1);
    final starts = <DateTime>[cursor];
    for (final length in lengths) {
      cursor = cursor.add(Duration(days: length));
      starts.add(cursor);
    }
    for (final start in starts) {
      await periods.upsertPeriod(
        startedOn: start,
        endedOn: start.add(const Duration(days: 4)),
        source: PeriodSources.settings,
      );
    }
  }

  rituTestWidgets('Variable user sees estimated phase and next-period range', (
    tester,
  ) async {
    await seedVariableHistory();
    final latest = await DriftPeriodRepository(database).getLatest();
    final lastStart = dateOnly(latest!.startedOn);
    final today = lastStart.add(const Duration(days: 8)); // cycle day 9

    await tester.pumpWidget(
      createRituApp(database: database, simulatedToday: today),
    );
    await tester.pumpAndSettle();

    expect(find.text('~Follicular phase'), findsOneWidget);
    expect(find.text('days into your cycle'), findsOneWidget);
    expect(
      find.text('Last period ${formatShortMonthDay(lastStart)}'),
      findsOneWidget,
    );
    // shortest 21 / longest 35 from last start
    final early = lastStart.add(const Duration(days: 21));
    final late = lastStart.add(const Duration(days: 35));
    final expectedRange = formatEstimatedShortMonthDayRange(early, late);
    expect(find.text('Next period $expectedRange'), findsOneWidget);
  });

  rituTestWidgets('Delete Data clears profile and returns to splash', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Delete Data'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Delete Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Data'));
    await tester.pumpAndSettle();

    expect(find.text('Delete everything'), findsOneWidget);
    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure?'), findsOneWidget);
    expect(
      find.text(
        'Once deleted, your logs, journal entries, insights, and reports cannot be recovered.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure?'), findsNothing);
    expect(find.text('Delete everything'), findsOneWidget);
    expect(await profiles.getProfile(), isNotNull);

    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Permanently delete'));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    expect(await profiles.getProfile(), isNull);
  });

  rituTestWidgets('Editing name from Settings updates profile and Home', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maya'));
    await tester.pumpAndSettle();

    expect(find.text('What should Ritu call you?'), findsOneWidget);
    expect(find.text('Change your first name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nora');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nora'), findsOneWidget);
    expect((await profiles.getProfile())?.displayName, 'Nora');

    await tester.tap(find.byIcon(LucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    expect(find.text('Nora ✨'), findsOneWidget);
  });

  rituTestWidgets('Period History from Settings adds past dates', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.setTypicalPeriodDays(5);
    await profiles.markOnboardingCompleted();

    final today = dateOnly(DateTime.now());
    final latestStart = today.subtract(const Duration(days: 3));
    final pastStart = today.subtract(const Duration(days: 20));
    await periods.upsertPeriod(
      startedOn: latestStart,
      endedOn: latestStart.add(const Duration(days: 4)),
      source: PeriodSources.onboardingLast,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    expect(find.text('No dates added'), findsOneWidget);
    expect(find.text('Period Started'), findsNothing);
    expect(find.text('Cycle Learning'), findsOneWidget);
    expect(find.text('Unclassified – needs 3 cycles'), findsOneWidget);
    expect(find.text('Insight Alerts'), findsNothing);
    expect(find.text('Period Reminder'), findsNothing);
    expect(find.text('iCloud Backup'), findsNothing);
    expect(find.text('Usage Analytics'), findsNothing);

    await tester.tap(find.text('Period History'));
    await tester.pumpAndSettle();

    expect(find.text('Period history'), findsOneWidget);
    expect(find.text('Logged'), findsOneWidget);
    expect(find.text('Current period'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.circlePlus));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Existing entries are marked so you don’t duplicate one'),
      findsOneWidget,
    );

    // Move calendar to the month of the past start if needed.
    final monthLabel = formatMonthYear(pastStart);
    for (var i = 0; i < 3 && find.text(monthLabel).evaluate().isEmpty; i++) {
      await tester.tap(find.byIcon(LucideIcons.chevronLeft).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    final day = find.text('${pastStart.day}');
    await tester.ensureVisible(day);
    await tester.tap(day);
    await tester.pumpAndSettle();

    final endedChip = find.text("It's ended");
    await tester.scrollUntilVisible(endedChip, 120);
    await tester.tap(endedChip);
    await tester.pumpAndSettle();

    final roughChip = find.text('Not sure - roughly');
    await tester.scrollUntilVisible(roughChip, 120);
    await tester.tap(roughChip);
    await tester.pumpAndSettle();

    final durationChip = find.text('4-5 days');
    await tester.scrollUntilVisible(durationChip, 120);
    await tester.tap(durationChip);
    await tester.pumpAndSettle();

    expect(await periods.getPastStartedOn(), isEmpty);

    final savePeriod = find.widgetWithText(FilledButton, 'Save period');
    await tester.ensureVisible(savePeriod);
    await tester.tap(savePeriod);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Manual'), findsOneWidget);

    final past = await periods.getPastStartedOn();
    expect(past, [pastStart]);
    expect(dateOnly((await periods.getLatest())!.startedOn), latestStart);
    final all = await periods.getAll();
    expect(all.last.source, PeriodSources.manual);
    expect(all.where((p) => p.isManual), hasLength(1));
    expect(all.where((p) => !p.isManual), hasLength(1));
  });

  rituTestWidgets('the only period cannot be deleted', (tester) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    final today = dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 3));
    await periods.upsertPeriod(
      startedOn: start,
      endedOn: start.add(const Duration(days: 4)),
      source: PeriodSources.onboardingLast,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Period History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Current period'));
    await tester.pumpAndSettle();

    final delete = find.text('Delete this period');
    await tester.scrollUntilVisible(delete, 120);
    expect(delete, findsOneWidget);
    expect(
      find.text(
        'You need at least one period date - add a new one before removing this.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'Delete this period'),
          )
          .onPressed,
      isNull,
    );
    expect(await periods.getAll(), hasLength(1));
  });

  rituTestWidgets('deleting a period can be undone from history', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    final today = dateOnly(DateTime.now());
    final latestStart = today.subtract(const Duration(days: 3));
    final olderStart = today.subtract(const Duration(days: 40));
    await periods.upsertPeriod(
      startedOn: latestStart,
      endedOn: latestStart.add(const Duration(days: 4)),
      source: PeriodSources.onboardingLast,
    );
    await periods.upsertPeriod(
      startedOn: olderStart,
      endedOn: olderStart.add(const Duration(days: 4)),
      source: PeriodSources.onboardingPast,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Period History'));
    await tester.pumpAndSettle();

    final olderLabel = formatShortMonthDay(olderStart);
    expect(find.text(olderLabel), findsOneWidget);
    await tester.tap(find.text('Oldest entry on record'));
    await tester.pumpAndSettle();

    final delete = find.text('Delete this period');
    await tester.scrollUntilVisible(delete, 120);
    expect(
      find.text(
        'You need at least one period date - add a new one before removing this.',
      ),
      findsNothing,
    );
    await tester.tap(delete);
    await tester.pumpAndSettle();

    expect(find.text('Period removed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text(olderLabel), findsNothing);
    expect(await periods.getAll(), hasLength(1));

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Period removed'), findsNothing);
    expect(find.text(olderLabel), findsOneWidget);
    expect(find.text('Oldest entry on record'), findsOneWidget);
    final restored = await periods.getAll();
    expect(
      restored.map((log) => dateOnly(log.startedOn)),
      contains(olderStart),
    );
    expect(
      restored
          .firstWhere((log) => dateOnly(log.startedOn) == olderStart)
          .source,
      PeriodSources.onboardingPast,
    );
  });

  rituTestWidgets('Export Data opens the export and import choices', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Export Data'), 200);
    await tester.tap(find.text('Export Data'));
    await tester.pumpAndSettle();

    expect(find.text('Export & Import'), findsOneWidget);
    expect(
      find.text(
        'Back up your journal, or restore it from a file you’ve exported before.',
      ),
      findsOneWidget,
    );
    expect(find.text('Download a copy of your data as a file'), findsOneWidget);
    expect(
      find.text('Restore from a previously exported file'),
      findsOneWidget,
    );
    expect(find.text('PDF report'), findsNothing);

    await tester.tap(find.text('Export Data'));
    await tester.pumpAndSettle();

    expect(find.text('Export your data'), findsOneWidget);
    expect(
      find.text(
        'Download a copy of your data as a JSON file. Raw data for backup or advanced use',
      ),
      findsOneWidget,
    );
    expect(find.text('Includes'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('Journal entries'), findsOneWidget);
    expect(find.text('Insights & patterns'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(find.text('Import from file'), findsNothing);
    expect(find.text('Export format'), findsNothing);
  });

  rituTestWidgets('Import Data opens the file chooser before replacing data', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Export Data'), 200);
    await tester.tap(find.text('Export Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import Data'));
    await tester.pumpAndSettle();

    expect(find.text('Import your data'), findsOneWidget);
    expect(
      find.text('Restore your data from a JSON file you exported before'),
      findsOneWidget,
    );
    expect(find.text('Tap to choose a file'), findsOneWidget);
    expect(find.text('Replace all data?'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Import'))
          .onPressed,
      isNull,
    );
  });

  rituTestWidgets('Import Data rejects a file that is not a Ritu backup', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(
      createRituApp(
        database: database,
        overrides: [
          restoreBackupPickerProvider.overrideWithValue(
            () async => const RestoreBackupFile(
              name: 'notes.json',
              sizeBytes: 12,
              contents: 'not json',
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Export Data'), 200);
    await tester.tap(find.text('Export Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tap to choose a file'));
    await tester.pumpAndSettle();

    expect(find.text('Tap to choose a different file'), findsOneWidget);
    expect(
      find.text("This file doesn't look like a Ritu backup"),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Import'))
          .onPressed,
      isNull,
    );
  });

  rituTestWidgets('Import Data asks before a valid file replaces everything', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    final backup = RituBackup(
      version: RituBackup.currentVersion,
      exportedAt: DateTime.utc(2026, 10, 1),
      profile: Profile(
        displayName: 'Nora',
        createdAt: DateTime.utc(2026, 1, 1),
        onboardingCompletedAt: DateTime.utc(2026, 1, 2),
        typicalPeriodDays: 5,
      ),
    );

    await tester.pumpWidget(
      createRituApp(
        database: database,
        overrides: [
          restoreBackupPickerProvider.overrideWithValue(
            () async => RestoreBackupFile(
              name: 'ritu_export_2026.json',
              sizeBytes: 184 * 1024,
              contents: backup.encodePretty(),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Export Data'), 200);
    await tester.tap(find.text('Export Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tap to choose a file'));
    await tester.pumpAndSettle();

    expect(find.text('ritu_export_2026.json'), findsOneWidget);
    expect(find.text('184 KB'), findsOneWidget);
    expect(
      find.text('Tap again if you want to select a different file'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Import'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await tester.pumpAndSettle();
    expect(find.text('This will replace your current data'), findsOneWidget);
    expect(find.text('Overwrite and continue'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('This will replace your current data'), findsNothing);
    expect(find.text('ritu_export_2026.json'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overwrite and continue'));
    await tester.pumpAndSettle();

    expect(find.text('Import your data'), findsNothing);
    expect(await profiles.getProfile(), isNotNull);
    expect((await profiles.getProfile())!.displayName, 'Nora');
  });

  rituTestWidgets('FAQ opens in place without the feedback box', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Help & Support'), 200);
    await tester.tap(find.text('Help & Support'));
    await tester.pumpAndSettle();

    expect(find.text('How does Ritu read my cycle?'), findsOneWidget);
    expect(find.text('How does Ritu predict my cycle?'), findsNothing);
    expect(find.textContaining("doesn't predict"), findsOneWidget);
    expect(find.textContaining('real data behind them'), findsNothing);
    expect(find.text('What’s on your mind'), findsNothing);
    expect(find.text('Tell us in detail...'), findsNothing);
    expect(find.text('Send feedback'), findsNothing);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text("Why don't I have insights yet?"));
    await tester.pumpAndSettle();
    expect(find.textContaining('real data behind them'), findsOneWidget);
    expect(find.textContaining("doesn't predict"), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('support@ritu.care'), findsOneWidget);
  });

  rituTestWidgets('About Ritu shows the header, mission, and rate row', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('About Ritu'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('About Ritu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About Ritu'));
    await tester.pumpAndSettle();

    expect(find.text('About Ritu'), findsOneWidget);
    expect(find.text('Ritu'), findsOneWidget);
    expect(find.text('A private journal for your cycle'), findsOneWidget);
    expect(find.text('Our mission'), findsOneWidget);
    expect(find.text('How Ritu helps'), findsOneWidget);
    expect(find.text('Capture your rhythm'), findsOneWidget);
    expect(find.text('Recognize patterns'), findsOneWidget);
    expect(find.text('Understand Yourself'), findsOneWidget);
    expect(find.text('Rate Ritu on the App store'), findsNothing);
  });

  rituTestWidgets('Privacy Policy and Terms open the Ritu website', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _RecordingUrlLauncher();
    UrlLauncherPlatform.instance = launcher;

    try {
      await tester.pumpWidget(createRituApp(database: database));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.settings));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Privacy Policy'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      expect(launcher.launched, 'https://www.ritu.care/privacy');

      await tester.ensureVisible(find.text('Terms of Service'));
      await tester.tap(find.text('Terms of Service'));
      await tester.pumpAndSettle();
      expect(launcher.launched, 'https://www.ritu.care/terms');
    } finally {
      UrlLauncherPlatform.instance = previousLauncher;
    }
  });

  rituTestWidgets('Cycle Learning explains an unclassified cycle', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cycle Learning'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Cycle Learning'));
    await tester.tap(find.text('Cycle Learning'));
    await tester.pumpAndSettle();

    expect(find.text('Learning your rhythm'), findsOneWidget);
    expect(
      find.text('Ritu needs more data to classify your cycle type'),
      findsOneWidget,
    );
    expect(find.text('Current status - Unclassified'), findsOneWidget);
    expect(find.text('Where you fall'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  rituTestWidgets('Cycle Learning shows a regular classification', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    await _logCycleLengths(periods, List<int>.filled(6, 28));

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cycle Learning'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Cycle Learning'));
    expect(find.text('Regular'), findsOneWidget);
    await tester.tap(find.text('Cycle Learning'));
    await tester.pumpAndSettle();

    expect(find.text('Personal average'), findsOneWidget);
    expect(find.text('28 days'), findsOneWidget);
    expect(find.text('±0 days'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(
      find.text(
        "They're all within about 4 days of each other, so you're Regular",
      ),
      findsOneWidget,
    );
    expect(find.text('Learning your rhythm'), findsNothing);
  });

  rituTestWidgets('Cycle Learning shows a variable classification', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    await _logCycleLengths(periods, [22, 34, 24, 36, 23, 35]);

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cycle Learning'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Cycle Learning'));
    await tester.tap(find.text('Cycle Learning'));
    await tester.pumpAndSettle();

    expect(find.text('22-36 days'), findsOneWidget);
    expect(find.text('Typical range'), findsOneWidget);
    expect(find.text('±6 days'), findsOneWidget);
    expect(
      find.text(
        "They differ by 5–9 days on average, so you're Variable, we'll show dates as ranges, not exact days",
      ),
      findsOneWidget,
    );
  });

  rituTestWidgets('Cycle Learning shows an unpredictable classification', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    await _logCycleLengths(periods, [21, 46, 22, 45, 23, 44]);

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cycle Learning'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Cycle Learning'));
    await tester.tap(find.text('Cycle Learning'));
    await tester.pumpAndSettle();

    expect(find.text('21-46 days'), findsOneWidget);
    expect(find.text('±12 days'), findsOneWidget);
    final bar = find.byKey(const Key('cycle-spectrum-bar'));
    expect(tester.getSize(bar).height, 5);
    expect(tester.getSize(bar).width, greaterThan(200));
    final segments = find.descendant(
      of: bar,
      matching: find.byType(DecoratedBox),
    );
    expect(segments, findsNWidgets(2));
    expect(tester.getSize(segments.first).height, 5);
    expect(tester.getSize(segments.first).width, greaterThan(50));
    expect(
      find.text(
        "They differ by 10 or more days on average, that's Unpredictable, not a diagnosis, just a pattern in your own data.",
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text(
        'This can change. Ritu re-checks every time you log a new period',
      ),
      200,
    );
    expect(
      find.text(
        'This can change. Ritu re-checks every time you log a new period',
      ),
      findsOneWidget,
    );
  });

  rituTestWidgets('Ended period history shows Last period', (tester) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    final today = dateOnly(DateTime.now());
    final startedOn = today.subtract(const Duration(days: 40));
    await periods.upsertPeriod(
      startedOn: startedOn,
      endedOn: today.subtract(const Duration(days: 35)),
      source: PeriodSources.manual,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Period History'));
    await tester.pumpAndSettle();

    expect(find.text('Last period'), findsOneWidget);
    expect(find.text('Current period'), findsNothing);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.text('-'), findsWidgets);
    expect(find.text(formatShortMonthDay(startedOn)), findsWidgets);
    expect(find.text(formatMonthDay(startedOn)), findsNothing);
  });

  rituTestWidgets(
    'Custom Symptoms from Settings adds and removes body signals',
    (tester) async {
      final profiles = DriftProfileRepository(database);
      await profiles.upsertDisplayName('Maya');
      await profiles.markOnboardingCompleted();

      await tester.pumpWidget(createRituApp(database: database));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Add your own symptoms to track'), findsOneWidget);

      await tester.tap(find.text('Custom Symptoms'));
      await tester.pumpAndSettle();

      expect(find.text('Add your own body signals'), findsOneWidget);
      final addButton = find.widgetWithText(OutlinedButton, 'Add body signal');
      expect(addButton, findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Leg pain');
      await tester.pump();
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('Leg pain'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );

      await tester.enterText(find.byType(TextField), 'Bacne');
      await tester.pump();
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('Bacne'), findsOneWidget);

      final symptomRepository = DriftSymptomRepository(database);
      final stored = await symptomRepository.getAll();
      expect(stored.map((s) => s.name), ['Leg pain', 'Bacne']);

      await tester.tap(find.byIcon(LucideIcons.x).first);
      await tester.pumpAndSettle();

      expect(find.text('Leg pain'), findsNothing);
      expect(await symptomRepository.getAll(), hasLength(1));

      await tester.tap(
        find.widgetWithIcon(IconButton, LucideIcons.chevronLeft),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 added'), findsOneWidget);
    },
  );

  rituTestWidgets('Next through an empty Log today does not count as logged', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsNothing);
    expect(find.text('Discard'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.chevronLeft),
      ),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.chevronLeft),
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text("Today's Reflection"), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save log'));
    await tester.pumpAndSettle();

    expect(find.text("Complete today's check-in"), findsOneWidget);
    expect(find.text('Logged today'), findsNothing);
    expect(
      await DriftDailyLogRepository(database).getByDate(DateTime.now()),
      isNull,
    );
    expect(
      await DriftJournalEntryRepository(database).getByDate(DateTime.now()),
      isNull,
    );
  });

  rituTestWidgets('Closing Log today discards an unsaved selection', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discard this log?'), findsNothing);
    expect(find.text("Complete today's check-in"), findsOneWidget);

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spotting'));
    await tester.pump();

    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pump();
    expect(find.text('Any flow today?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discard this log?'), findsOneWidget);
    expect(
      find.text("What you've entered so far won't be saved."),
      findsOneWidget,
    );

    await tester.tap(find.text('Keep logging'));
    await tester.pumpAndSettle();
    expect(find.text('Any flow today?'), findsOneWidget);
    expect(find.text('Discard this log?'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text("Complete today's check-in"), findsOneWidget);
    expect(
      await DriftDailyLogRepository(database).getByDate(DateTime.now()),
      isNull,
    );
  });

  rituTestWidgets('Next saves the current Log today step', (tester) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('How are you feeling?'), findsOneWidget);
    expect(
      (await DriftDailyLogRepository(
        database,
      ).getByDate(DateTime.now()))?.flowIntensity,
      'Light',
    );

    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discard this log?'), findsOneWidget);
    await tester.tap(find.text('Keep logging'));
    await tester.pumpAndSettle();
    expect(find.text('How are you feeling?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text("Complete today's check-in"), findsOneWidget);
    expect(
      await DriftDailyLogRepository(database).getByDate(DateTime.now()),
      isNull,
    );
    expect(
      await DriftJournalEntryRepository(database).getByDate(DateTime.now()),
      isNull,
    );
  });

  rituTestWidgets('Discarding edits keeps the log that was already saved', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    await DriftDailyLogRepository(
      database,
    ).upsert(loggedOn: DateTime.now(), flowIntensity: 'Light');

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discard this log?'), findsNothing);
    expect(find.text('Logged today'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Heavy'));
    await tester.pump();
    expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discard your changes?'), findsOneWidget);
    expect(find.text('Your original log stays as it was.'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('How are you feeling?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(DailyLogFlow),
        matching: find.byIcon(LucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();

    expect(find.text('Light flow'), findsOneWidget);
    expect(
      (await DriftDailyLogRepository(
        database,
      ).getByDate(DateTime.now()))?.flowIntensity,
      'Light',
    );
  });

  rituTestWidgets('Log today records a full daily log entry', (tester) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text("Complete today's check-in"), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(LucideIcons.flame)).color,
      RituColors.textDisabled,
    );
    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();

    // Step 1: flow.
    expect(find.text('Any flow today?'), findsOneWidget);
    await tester.tap(find.text('Spotting'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    // Step 2: mood.
    expect(find.text('How are you feeling?'), findsOneWidget);
    await tester.tap(find.text('Calm'));
    await tester.pump();
    await tester.tap(find.text('Happy'));
    await tester.pump();
    await tester.ensureVisible(find.text('Moderate'));
    await tester.tap(find.text('Moderate'));
    await tester.pump();
    await tester.ensureVisible(find.text('Okay'));
    await tester.tap(find.text('Okay'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Next'));
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    // Step 3: body signals, including adding a brand-new one inline.
    expect(find.text('Any body signals?'), findsOneWidget);
    await tester.ensureVisible(find.text('Bloating'));
    await tester.tap(find.text('Bloating'));
    await tester.pump();

    await tester.ensureVisible(find.text('Add your own'));
    await tester.tap(find.text('Add your own'));
    await tester.pumpAndSettle();
    expect(find.text('Add your own body signal'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Custom ache');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Custom ache'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    // Step 4: notes + save.
    expect(find.text("Today's Reflection"), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Feeling okay today');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save log'));
    await tester.pumpAndSettle();

    expect(find.text('Logged today'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Spotting flow'), findsOneWidget);
    expect(find.text('Calm'), findsOneWidget);
    expect(find.text('Moderate energy'), findsOneWidget);
    expect(find.text('Okay sleep'), findsOneWidget);
    expect(find.text('Bloating'), findsOneWidget);
    expect(find.text('Custom ache'), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(LucideIcons.flame)).color,
      RituColors.iconAttention,
    );

    final dailyLogs = DriftDailyLogRepository(database);
    final entry = await dailyLogs.getByDate(DateTime.now());
    expect(entry, isNotNull);
    expect(entry!.flowIntensity, 'Spotting');
    expect(entry.moods, containsAll(['Calm', 'Happy']));
    expect(entry.energyLevel, 'Moderate');
    expect(entry.sleepQuality, 'Okay');
    expect(entry.symptoms, containsAll(['Bloating', 'Custom ache']));
    expect(await dailyLogs.getCurrentStreak(), 1);

    final journal = DriftJournalEntryRepository(database);
    final journalEntry = await journal.getByDate(DateTime.now());
    expect(journalEntry?.body, 'Feeling okay today');

    final symptomRepository = DriftSymptomRepository(database);
    final storedSymptoms = await symptomRepository.getAll();
    expect(storedSymptoms.map((s) => s.name), contains('Custom ache'));
  });

  rituTestWidgets('Log today re-opens with previous answers pre-filled', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    final dailyLogs = DriftDailyLogRepository(database);
    await dailyLogs.upsert(
      loggedOn: DateTime.now(),
      flowIntensity: 'Light',
      moods: const ['Focused'],
    );
    await DriftJournalEntryRepository(
      database,
    ).upsert(loggedOn: DateTime.now(), body: 'Already logged this morning');

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Logged today'), findsOneWidget);
    expect(find.text('Light flow'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Any flow today?'), findsOneWidget);
    final light = tester.widget<RituChoiceChip>(
      find.widgetWithText(RituChoiceChip, 'Light'),
    );
    expect(light.selected, isTrue);

    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();
    expect(find.text('Focused'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();
    expect(find.text("Today's Reflection"), findsOneWidget);
    expect(
      find.text("Share anything you'd like to remember about today."),
      findsOneWidget,
    );
    expect(
      find.text('Every reflection is saved to your Journal'),
      findsOneWidget,
    );
    expect(find.text('Already logged this morning'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save changes'), findsOneWidget);
    final reflectionField = tester.widget<TextField>(find.byType(TextField));
    expect(reflectionField.decoration?.enabledBorder, InputBorder.none);
    expect(reflectionField.decoration?.focusedBorder, InputBorder.none);
  });

  rituTestWidgets('Patterns progress counts logged days, not past periods', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    final dailyLogs = DriftDailyLogRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    await periods.upsertPeriod(
      startedOn: DateTime(2026, 6, 1),
      endedOn: DateTime(2026, 6, 5),
      source: PeriodSources.onboardingLast,
    );
    await periods.addPastStart(
      startedOn: DateTime(2026, 5, 1),
      typicalPeriodDays: 5,
    );
    await periods.addPastStart(
      startedOn: DateTime(2026, 4, 1),
      typicalPeriodDays: 5,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    // Three periods logged, but zero daily logs yet — hide the card.
    expect(find.text('Your patterns will appear here'), findsNothing);
    expect(find.text('0 of 14 days – pattern unlock at 14'), findsNothing);

    await dailyLogs.upsert(loggedOn: DateTime.now(), flowIntensity: 'Light');
    await dailyLogs.upsert(
      loggedOn: DateTime.now().subtract(const Duration(days: 1)),
      flowIntensity: 'Light',
    );

    await tester.pump();

    expect(find.text('Your patterns will appear here'), findsOneWidget);
    expect(find.text('2 of 14 days – pattern unlock at 14'), findsOneWidget);
    expect(find.text('Your first insights are ready 🎉'), findsNothing);

    for (var day = 2; day < 14; day++) {
      await dailyLogs.upsert(
        loggedOn: DateTime.now().subtract(Duration(days: day)),
        flowIntensity: 'Light',
      );
    }
    await tester.pump();

    expect(find.text('Your first insights are ready 🎉'), findsOneWidget);
    expect(find.text('Your patterns will appear here'), findsNothing);
    expect(find.textContaining('pattern unlock at'), findsNothing);

    await tester.tap(find.text('See insights'));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Your first insights are ready 🎉'), findsNothing);
  });

  rituTestWidgets('Mood log pills keep design gaps and show full labels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    Rect chipRect(String label) {
      return tester.getRect(
        find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first,
      );
    }

    final highText = tester.getRect(find.text('High'));
    final highChip = chipRect('High');
    expect(highChip.height, 34);
    expect(highText.left - highChip.left, greaterThanOrEqualTo(12));
    expect(highChip.right - highText.right, greaterThanOrEqualTo(12));
    expect(highText.top, greaterThanOrEqualTo(highChip.top));
    expect(highText.bottom, lessThanOrEqualTo(highChip.bottom));
    expect(highText.center.dy, closeTo(highChip.center.dy, 1));

    final drained = chipRect('Drained');
    final low = chipRect('Low');
    expect(low.left - drained.right, closeTo(8, 0.1));
    expect(low.top, drained.top);

    final moderate = chipRect('Moderate');
    if ((moderate.top - drained.top).abs() < 1) {
      expect(moderate.left - low.right, closeTo(8, 0.1));
      expect(highChip.top, drained.top);
    } else {
      expect(moderate.top - drained.bottom, closeTo(16, 0.1));
    }
    final vibrant = chipRect('Vibrant');
    final vibrantAnchor = (highChip.top - drained.top).abs() < 1
        ? highChip
        : drained;
    if ((vibrant.top - vibrantAnchor.top).abs() < 1) {
      expect(vibrant.left, greaterThan(vibrantAnchor.right));
    } else {
      expect(vibrant.top - vibrantAnchor.bottom, closeTo(16, 0.1));
    }

    const moodLabels = [
      'Calm',
      'Irritable',
      'Focused',
      'Anxious',
      'Flat',
      'Sad',
      'Happy',
      'Overwhelmed',
      'Content',
      'Restless',
    ];
    final calm = chipRect('Calm');
    final wrapped = moodLabels
        .skip(1)
        .map(chipRect)
        .firstWhere((rect) => rect.top > calm.top + 1);
    expect(wrapped.top - calm.bottom, closeTo(16, 0.1));
  });

  testWidgets('RituChoiceChip options in a Wrap lay out side by side', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RituChoiceChip(label: 'None', selected: false, onTap: () {}),
              RituChoiceChip(label: 'Spotting', selected: false, onTap: () {}),
              RituChoiceChip(label: 'Light', selected: false, onTap: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final noneTopLeft = tester.getTopLeft(find.text('None'));
    final spottingTopLeft = tester.getTopLeft(find.text('Spotting'));
    final lightTopLeft = tester.getTopLeft(find.text('Light'));

    // Chips should sit on the same row (equal dy) and flow left-to-right
    // (increasing dx), not stack vertically full-width.
    expect(spottingTopLeft.dy, noneTopLeft.dy);
    expect(lightTopLeft.dy, noneTopLeft.dy);
    expect(spottingTopLeft.dx, greaterThan(noneTopLeft.dx));
    expect(lightTopLeft.dx, greaterThan(spottingTopLeft.dx));

    final noneChipSize = tester.getSize(
      find
          .ancestor(of: find.text('None'), matching: find.byType(Container))
          .first,
    );
    expect(noneChipSize.width, lessThan(200));
  });
}
