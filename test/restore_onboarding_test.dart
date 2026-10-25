import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ritu/app/ritu_app.dart';
import 'package:ritu/data/backup/restore_backup_file.dart';
import 'package:ritu/data/backup/ritu_backup.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/models/profile.dart';
import 'package:ritu/data/repositories/drift/drift_profile_repository.dart';
import 'package:ritu/features/onboarding/restore_confirmation_screen.dart';
import 'package:ritu/providers/repository_providers.dart';

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

  RestoreBackupFile validFile() {
    final backup = RituBackup(
      version: RituBackup.currentVersion,
      exportedAt: DateTime.utc(2026, 10, 1),
      profile: Profile(
        displayName: 'Maya',
        createdAt: DateTime.utc(2026, 1, 1),
        onboardingCompletedAt: DateTime.utc(2026, 1, 2),
        typicalPeriodDays: 5,
      ),
    );
    return RestoreBackupFile(
      name: 'ritu_export_2026.json',
      sizeBytes: 184 * 1024,
      contents: backup.encodePretty(),
    );
  }

  rituTestWidgets('Restore from backup imports a file and opens home', (
    tester,
  ) async {
    await tester.pumpWidget(
      createRituApp(
        database: database,
        overrides: [
          restoreBackupPickerProvider.overrideWithValue(
            () async => validFile(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore from backup'));
    await tester.pumpAndSettle();

    expect(find.text('Restore your data'), findsOneWidget);
    expect(find.text('Tap to choose a file'), findsOneWidget);
    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);

    await tester.tap(find.text('Tap to choose a file'));
    await tester.pumpAndSettle();

    expect(find.text('ritu_export_2026.json'), findsOneWidget);
    expect(find.text('184 KB'), findsOneWidget);
    expect(find.text('Want to start fresh? Sign in'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Your data has been fully restored'), findsOneWidget);
    expect(find.text('👋'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(RestoreConfirmationScreen),
        matching: find.text('Continue'),
      ),
    );
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Welcome,').evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    final profile = await DriftProfileRepository(database).getProfile();
    expect(profile?.displayName, 'Maya');
    expect(profile?.hasCompletedOnboarding, isTrue);
  });

  rituTestWidgets('An unreadable backup shows the import error', (
    tester,
  ) async {
    await tester.pumpWidget(
      createRituApp(
        database: database,
        overrides: [
          restoreBackupPickerProvider.overrideWithValue(
            () async => const RestoreBackupFile(
              name: 'notes.json',
              sizeBytes: 20,
              contents: '{"hello":true}',
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore from backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tap to choose a file'));
    await tester.pumpAndSettle();

    expect(find.text('Tap to choose a different file'), findsOneWidget);
    expect(
      find.text('This file doesn’t look like a Ritu backup'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
          .onPressed,
      isNull,
    );
  });

  rituTestWidgets('Start fresh from restore continues into the name step', (
    tester,
  ) async {
    await tester.pumpWidget(createRituApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore from backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Don’t have a backup? Start fresh instead'));
    await tester.pumpAndSettle();

    expect(find.text('What should Ritu call you?'), findsOneWidget);
  });
}
