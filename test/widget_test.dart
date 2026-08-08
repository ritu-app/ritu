import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ritu/app/ritu_app.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/repositories/drift/drift_daily_log_repository.dart';
import 'package:ritu/data/repositories/drift/drift_journal_entry_repository.dart';
import 'package:ritu/data/repositories/drift/drift_period_repository.dart';
import 'package:ritu/data/repositories/drift/drift_profile_repository.dart';
import 'package:ritu/data/repositories/drift/drift_symptom_repository.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/features/setup/widgets/choice_chips.dart';
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
    await tester.tap(find.text('This look right'));
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

    await tester.ensureVisible(find.text('4-5 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4-5 days'));
    await tester.pump();
    await tester.tap(find.text('This look right'));
    await tester.pumpAndSettle();

    final periods = DriftPeriodRepository(database);
    final latest = await periods.getLatest();
    expect(latest, isNotNull);
    expect(latest!.source, PeriodSources.onboardingLast);

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

  rituTestWidgets(
    'Regular user in ovulatory phase sees golden header',
    (tester) async {
      await seedRegularHistory();

      await tester.pumpWidget(
        createRituApp(
          database: database,
          simulatedToday: DateTime(2026, 4, 14),
        ),
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
    },
  );

  rituTestWidgets(
    'Regular user in menstrual phase sees rose header',
    (tester) async {
      await seedRegularHistory();

      await tester.pumpWidget(
        createRituApp(
          database: database,
          simulatedToday: DateTime(2026, 4, 3),
        ),
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
    },
  );

  rituTestWidgets(
    'Regular user in luteal phase sees lilac header',
    (tester) async {
      await seedRegularHistory();

      await tester.pumpWidget(
        createRituApp(
          database: database,
          simulatedToday: DateTime(2026, 4, 26),
        ),
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
    },
  );

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

  rituTestWidgets('Editing period started from Settings updates latest log', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.setTypicalPeriodDays(5);
    await profiles.markOnboardingCompleted();
    await periods.upsertPeriod(
      startedOn: DateTime(2026, 6, 1),
      endedOn: DateTime(2026, 6, 5),
      source: PeriodSources.onboardingLast,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    expect(find.text(formatDisplayDate(DateTime(2026, 6, 1))), findsOneWidget);

    await tester.tap(find.text('Period Started'));
    await tester.pumpAndSettle();

    expect(find.text('When did your last period start?'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    final day15 = find.text('15');
    expect(day15, findsOneWidget);
    await tester.ensureVisible(day15);
    await tester.tap(day15);
    await tester.pump();

    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    final settingsLabel = formatDisplayDate(DateTime(2026, 6, 15));
    expect(find.text(settingsLabel), findsOneWidget);

    final latest = await periods.getLatest();
    expect(latest, isNotNull);
    expect(dateOnly(latest!.startedOn), DateTime(2026, 6, 15));
    expect(dateOnly(latest.endedOn!), DateTime(2026, 6, 19));
    expect(latest.source, PeriodSources.settings);

    await tester.tap(find.byIcon(LucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    expect(
      find.text('Last period ${formatShortMonthDay(DateTime(2026, 6, 15))}'),
      findsOneWidget,
    );
  });

  rituTestWidgets('Period start calendar does not accept future dates', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    await periods.upsertPeriod(
      startedOn: DateTime.now(),
      source: PeriodSources.onboardingLast,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Period Started'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);

    // Move to next month (should be blocked) and try a late day in current month.
    final forward = find.byIcon(LucideIcons.chevronRight);
    await tester.tap(forward);
    await tester.pumpAndSettle();

    // Still on current month — month title includes current year/month name.
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    expect(find.text('${months[now.month - 1]} ${now.year}'), findsOneWidget);

    if (now.day < 28) {
      final futureDay = find.text('${now.day + 1}');
      await tester.ensureVisible(futureDay);
      await tester.tap(futureDay);
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final latest = await periods.getLatest();
      expect(dateOnly(latest!.startedOn), dateOnly(now));
    }

    expect(
      () => periods.upsertPeriod(
        startedOn: DateTime.now().add(const Duration(days: 3)),
        source: PeriodSources.settings,
      ),
      throwsArgumentError,
    );
  });

  rituTestWidgets('Period History from Settings adds past dates', (tester) async {
    final profiles = DriftProfileRepository(database);
    final periods = DriftPeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.setTypicalPeriodDays(5);
    await profiles.markOnboardingCompleted();
    await periods.upsertPeriod(
      startedOn: DateTime(2026, 6, 20),
      endedOn: DateTime(2026, 6, 24),
      source: PeriodSources.onboardingLast,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    expect(find.text('No dates added'), findsOneWidget);

    await tester.tap(find.text('Period History'));
    await tester.pumpAndSettle();

    expect(find.text('Do you have past period dates?'), findsOneWidget);
    expect(find.text('Add a date'), findsOneWidget);
    expect(find.text('Save'), findsNothing);

    // Calendar is always visible; selecting a day only stages it — it's
    // stored once "Add a date" is pressed.
    await tester.ensureVisible(find.text('1'));
    await tester.tap(find.text('1'));
    await tester.pump();

    expect(await periods.getPastStartedOn(), isEmpty);

    final addDate = find.widgetWithText(OutlinedButton, 'Add a date');
    await tester.ensureVisible(addDate);
    await tester.tap(addDate);
    await tester.pumpAndSettle();

    expect(find.text('Jun 1'), findsOneWidget);

    final past = await periods.getPastStartedOn();
    expect(past, [DateTime(2026, 6, 1)]);
    expect(
      dateOnly((await periods.getLatest())!.startedOn),
      DateTime(2026, 6, 20),
    );

    await tester.tap(find.widgetWithIcon(IconButton, LucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    expect(find.text('View and edit past dates'), findsOneWidget);
  });

  rituTestWidgets('Custom Symptoms from Settings adds and removes body signals', (
    tester,
  ) async {
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

    await tester.tap(find.widgetWithIcon(IconButton, LucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    expect(find.text('1 added'), findsOneWidget);
  });

  rituTestWidgets('Skipping every Log today step does not count as logged', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Notes'), findsOneWidget);
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
    expect(find.text('Notes'), findsOneWidget);
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
    await DriftJournalEntryRepository(database).upsert(
      loggedOn: DateTime.now(),
      body: 'Already logged this morning',
    );

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

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Focused'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Already logged this morning'), findsOneWidget);
  });

  rituTestWidgets(
    'Patterns progress counts logged days, not past periods',
    (tester) async {
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
    },
  );

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
      find.ancestor(
        of: find.text('None'),
        matching: find.byType(Container),
      ).first,
    );
    expect(noneChipSize.width, lessThan(200));
  });
}
