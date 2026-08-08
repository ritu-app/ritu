import 'package:flutter_test/flutter_test.dart';

import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/backup/ritu_backup.dart';
import 'package:ritu/data/backup/ritu_backup_service.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/models/period_log.dart';
import 'package:ritu/data/models/profile.dart';
import 'package:ritu/data/repositories/drift/drift_daily_log_repository.dart';
import 'package:ritu/data/repositories/drift/drift_journal_entry_repository.dart';
import 'package:ritu/data/repositories/drift/drift_period_repository.dart';
import 'package:ritu/data/repositories/drift/drift_profile_repository.dart';
import 'package:ritu/data/repositories/drift/drift_symptom_repository.dart';

void main() {
  group('RituBackup codec', () {
    test('round-trips selected sections', () {
      final original = RituBackup(
        version: RituBackup.currentVersion,
        exportedAt: DateTime.utc(2026, 8, 8, 12),
        profile: Profile(
          displayName: 'Maya',
          createdAt: DateTime.utc(2026, 1, 1),
          onboardingCompletedAt: DateTime.utc(2026, 1, 2),
          typicalPeriodDays: 5,
        ),
        periodLogs: [
          PeriodLog(
            id: 1,
            startedOn: DateTime(2026, 7, 1),
            endedOn: DateTime(2026, 7, 5),
            source: PeriodSources.settings,
            createdAt: DateTime.utc(2026, 7, 1),
            updatedAt: DateTime.utc(2026, 7, 1),
          ),
        ],
        journalEntries: const [],
        dailyLogs: const [],
        customSymptoms: const [],
      );

      final decoded = RituBackup.decode(original.encodePretty());
      expect(decoded.version, 1);
      expect(decoded.profile?.displayName, 'Maya');
      expect(decoded.profile?.typicalPeriodDays, 5);
      expect(decoded.periodLogs, hasLength(1));
      expect(decoded.periodLogs.single.startedOn, DateTime(2026, 7, 1));
      expect(decoded.dailyLogs, isEmpty);
      expect(decoded.journalEntries, isEmpty);
    });

    test('rejects invalid format', () {
      expect(
        () => RituBackup.decode('{"format":"other","version":1}'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing profile fields on decode of bad profile', () {
      expect(
        () => RituBackup.decode('''
{
  "format": "ritu.backup",
  "version": 1,
  "exportedAt": "2026-08-08T12:00:00.000Z",
  "profile": { "createdAt": "2026-01-01T00:00:00.000Z" }
}
'''),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('RituBackupService', () {
    late AppDatabase database;
    late RituBackupService service;
    late DriftProfileRepository profiles;
    late DriftPeriodRepository periods;
    late DriftDailyLogRepository dailyLogs;
    late DriftJournalEntryRepository journalEntries;
    late DriftSymptomRepository symptoms;

    setUp(() {
      database = AppDatabase.memory();
      profiles = DriftProfileRepository(database);
      periods = DriftPeriodRepository(database);
      dailyLogs = DriftDailyLogRepository(database);
      journalEntries = DriftJournalEntryRepository(database);
      symptoms = DriftSymptomRepository(database);
      service = RituBackupService(
        profiles: profiles,
        periods: periods,
        dailyLogs: dailyLogs,
        journalEntries: journalEntries,
        symptoms: symptoms,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('export/import round-trip restores data', () async {
      await profiles.upsertDisplayName('Maya');
      await profiles.setTypicalPeriodDays(5);
      await profiles.markOnboardingCompleted();

      final today = dateOnly(DateTime.now());
      await periods.upsertPeriod(
        startedOn: today.subtract(const Duration(days: 10)),
        endedOn: today.subtract(const Duration(days: 6)),
        source: PeriodSources.settings,
      );
      await dailyLogs.upsert(
        loggedOn: today.subtract(const Duration(days: 1)),
        flowIntensity: 'Light',
        moods: const ['Calm'],
      );
      await journalEntries.upsert(
        loggedOn: today.subtract(const Duration(days: 1)),
        body: 'Felt okay',
      );
      await symptoms.addSymptom('Bloating');

      final json = await service.exportJson(
        includeLogs: true,
        includeJournal: true,
        includeSettings: true,
      );

      await profiles.clearAllData();
      expect(await profiles.getProfile(), isNull);

      await service.importJson(json);

      final profile = await profiles.getProfile();
      expect(profile?.displayName, 'Maya');
      expect(profile?.typicalPeriodDays, 5);
      expect(profile?.hasCompletedOnboarding, isTrue);

      final allPeriods = await periods.getAll();
      expect(allPeriods, hasLength(1));

      final allLogs = await dailyLogs.getAll();
      expect(allLogs, hasLength(1));
      expect(allLogs.single.flowIntensity, 'Light');

      final allJournal = await journalEntries.getAll();
      expect(allJournal, hasLength(1));
      expect(allJournal.single.body, 'Felt okay');

      final allSymptoms = await symptoms.getAll();
      expect(allSymptoms.map((s) => s.name), contains('Bloating'));
    });

    test('selective export omits unchecked sections', () async {
      await profiles.upsertDisplayName('Maya');
      await profiles.markOnboardingCompleted();
      await journalEntries.upsert(
        loggedOn: DateTime.now(),
        body: 'Only journal',
      );

      final json = await service.exportJson(
        includeLogs: false,
        includeJournal: true,
        includeSettings: false,
      );
      final backup = RituBackup.decode(json);
      expect(backup.profile, isNull);
      expect(backup.periodLogs, isEmpty);
      expect(backup.dailyLogs, isEmpty);
      expect(backup.journalEntries, hasLength(1));
    });

    test('import requires profile', () async {
      final json = RituBackup(
        version: 1,
        exportedAt: DateTime.utc(2026, 8, 8),
        journalEntries: const [],
      ).encodePretty();

      await expectLater(
        service.importJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
