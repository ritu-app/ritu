import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ritu/app/ritu_app.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/data/repositories/profile_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Splash screen shows Ritu branding and CTA', (tester) async {
    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Ritu'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('Onboarding completes into homepage and persists name', (
    tester,
  ) async {
    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Maya 👋'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('This look right'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip – I’ll build from today'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Maya ✨'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    final profile = await ProfileRepository(database).getProfile();
    expect(profile?.displayName, 'Maya');
    expect(profile?.hasCompletedOnboarding, isTrue);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Maya'), findsOneWidget);
    expect(
      find.text('Logging since ${formatDisplayDate(profile!.onboardingCompletedAt!)}'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Understand your patterns'), findsOneWidget);

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('Your space to reflect'), findsOneWidget);

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Export your health data'), findsOneWidget);

    final periods = PeriodRepository(database);
    expect(await periods.getLatest(), isNotNull);
  });

  testWidgets('Last period and past dates are stored from setup', (tester) async {
    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('This look right'));
    await tester.pumpAndSettle();

    final periods = PeriodRepository(database);
    final latest = await periods.getLatest();
    expect(latest, isNotNull);
    expect(latest!.source, PeriodSources.onboardingLast);

    final profiles = ProfileRepository(database);
    expect((await profiles.getProfile())?.typicalPeriodDays, 5);

    await tester.tap(find.text('Skip – I’ll build from today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('days since last period'), findsOneWidget);
  });

  testWidgets('Returning user skips onboarding when profile is complete', (
    tester,
  ) async {
    final profiles = ProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsNothing);
    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Maya ✨'), findsOneWidget);
  });

  testWidgets('Delete Data clears profile and returns to splash', (tester) async {
    final profiles = ProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
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

    expect(find.text('Delete all data?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    expect(await profiles.getProfile(), isNull);
  });

  testWidgets('Editing name from Settings updates profile and Home', (
    tester,
  ) async {
    final profiles = ProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
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

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.text('Nora ✨'), findsOneWidget);
  });

  testWidgets('Editing period started from Settings updates latest log', (
    tester,
  ) async {
    final profiles = ProfileRepository(database);
    final periods = PeriodRepository(database);
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

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text(formatDisplayDate(DateTime(2026, 6, 1))), findsOneWidget);

    await tester.tap(find.text('Period Started'));
    await tester.pumpAndSettle();

    expect(find.text('What did your last period start?'), findsOneWidget);
    expect(
      find.text('Change the start date of your latest period'),
      findsOneWidget,
    );

    final dialog = find.byType(Dialog);
    final day15 = find.descendant(of: dialog, matching: find.text('15'));
    expect(day15, findsOneWidget);
    await tester.ensureVisible(day15);
    await tester.tap(day15);
    await tester.pump();

    final save = find.descendant(
      of: dialog,
      matching: find.widgetWithText(FilledButton, 'Save'),
    );
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    final updatedLabel = formatDisplayDate(DateTime(2026, 6, 15));
    expect(find.text(updatedLabel), findsOneWidget);

    final latest = await periods.getLatest();
    expect(latest, isNotNull);
    expect(dateOnly(latest!.startedOn), DateTime(2026, 6, 15));
    expect(dateOnly(latest.endedOn!), DateTime(2026, 6, 19));
    expect(latest.source, PeriodSources.settings);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.text('Last period $updatedLabel'), findsOneWidget);
  });

  testWidgets('Period start calendar does not accept future dates', (
    tester,
  ) async {
    final profiles = ProfileRepository(database);
    final periods = PeriodRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();
    await periods.upsertPeriod(
      startedOn: DateTime.now(),
      source: PeriodSources.onboardingLast,
    );

    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Period Started'));
    await tester.pumpAndSettle();

    final dialog = find.byType(Dialog);
    // Move to next month (should be blocked) and try a late day in current month.
    final forward = find.descendant(
      of: dialog,
      matching: find.byIcon(Icons.chevron_right),
    );
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
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('${months[now.month - 1]} ${now.year}'),
      ),
      findsOneWidget,
    );

    if (now.day < 28) {
      final futureDay = find.descendant(
        of: dialog,
        matching: find.text('${now.day + 1}'),
      );
      await tester.ensureVisible(futureDay);
      await tester.tap(futureDay);
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: dialog,
          matching: find.widgetWithText(FilledButton, 'Save'),
        ),
      );
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
}
