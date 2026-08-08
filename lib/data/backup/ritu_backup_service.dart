import '../repositories/daily_log_repository.dart';
import '../repositories/journal_entry_repository.dart';
import '../repositories/period_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/symptom_repository.dart';
import 'ritu_backup.dart';

class RituBackupService {
  RituBackupService({
    required ProfileRepository profiles,
    required PeriodRepository periods,
    required DailyLogRepository dailyLogs,
    required JournalEntryRepository journalEntries,
    required SymptomRepository symptoms,
  })  : _profiles = profiles,
        _periods = periods,
        _dailyLogs = dailyLogs,
        _journalEntries = journalEntries,
        _symptoms = symptoms;

  final ProfileRepository _profiles;
  final PeriodRepository _periods;
  final DailyLogRepository _dailyLogs;
  final JournalEntryRepository _journalEntries;
  final SymptomRepository _symptoms;

  Future<String> exportJson({
    required bool includeLogs,
    required bool includeJournal,
    required bool includeSettings,
  }) async {
    if (!includeLogs && !includeJournal && !includeSettings) {
      throw StateError('Select at least one section to export');
    }

    final backup = RituBackup(
      version: RituBackup.currentVersion,
      exportedAt: DateTime.now().toUtc(),
      profile: includeSettings ? await _profiles.getProfile() : null,
      periodLogs: includeLogs ? await _periods.getAll() : const [],
      dailyLogs: includeLogs ? await _dailyLogs.getAll() : const [],
      journalEntries:
          includeJournal ? await _journalEntries.getAll() : const [],
      customSymptoms: includeSettings ? await _symptoms.getAll() : const [],
    );

    if (includeSettings && backup.profile == null) {
      throw StateError('Cannot export settings without a profile');
    }

    return backup.encodePretty();
  }

  /// Replace-all restore from a `ritu.backup` JSON string.
  Future<void> importJson(String raw) async {
    final backup = RituBackup.decode(raw);
    if (backup.profile == null) {
      throw const FormatException(
        'Backup is missing a profile. Export with Settings included.',
      );
    }

    await _profiles.clearAllData();
    await _profiles.restoreProfile(backup.profile!);

    for (final log in backup.periodLogs) {
      await _periods.upsertPeriod(
        startedOn: log.startedOn,
        endedOn: log.endedOn,
        source: log.source,
      );
    }

    for (final entry in backup.dailyLogs) {
      await _dailyLogs.upsert(
        loggedOn: entry.loggedOn,
        flowIntensity: entry.flowIntensity,
        crampIntensity: entry.crampIntensity,
        moods: entry.moods,
        energyLevel: entry.energyLevel,
        sleepQuality: entry.sleepQuality,
        wellbeing: entry.wellbeing,
        symptoms: entry.symptoms,
      );
    }

    for (final entry in backup.journalEntries) {
      await _journalEntries.upsert(
        loggedOn: entry.loggedOn,
        body: entry.body,
      );
    }

    for (final symptom in backup.customSymptoms) {
      await _symptoms.addSymptom(symptom.name);
    }
  }
}
