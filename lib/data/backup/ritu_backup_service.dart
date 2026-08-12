import '../../core/date_format.dart';
import '../models/period_end_prompt.dart';
import '../models/period_log.dart';
import '../repositories/daily_log_repository.dart';
import '../repositories/journal_entry_repository.dart';
import '../repositories/period_end_prompt_repository.dart';
import '../repositories/period_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/symptom_repository.dart';
import 'ritu_backup.dart';

class RituBackupService {
  RituBackupService({
    required ProfileRepository profiles,
    required PeriodRepository periods,
    required PeriodEndPromptRepository periodEndPrompts,
    required DailyLogRepository dailyLogs,
    required JournalEntryRepository journalEntries,
    required SymptomRepository symptoms,
  })  : _profiles = profiles,
        _periods = periods,
        _periodEndPrompts = periodEndPrompts,
        _dailyLogs = dailyLogs,
        _journalEntries = journalEntries,
        _symptoms = symptoms;

  final ProfileRepository _profiles;
  final PeriodRepository _periods;
  final PeriodEndPromptRepository _periodEndPrompts;
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

    final periodLogs =
        includeLogs ? await _periods.getAll() : const <PeriodLog>[];
    final periodById = {
      for (final log in periodLogs) log.id: log,
    };

    final backup = RituBackup(
      version: RituBackup.currentVersion,
      exportedAt: DateTime.now().toUtc(),
      profile: includeSettings ? await _profiles.getProfile() : null,
      periodLogs: periodLogs,
      periodEndPrompts: includeLogs
          ? [
              for (final prompt in await _periodEndPrompts.getAll())
                if (periodById[prompt.periodLogId] != null)
                  PeriodEndPrompt(
                    id: prompt.id,
                    periodLogId: prompt.periodLogId,
                    shownOn: prompt.shownOn,
                    response: prompt.response,
                    respondedOn: prompt.respondedOn,
                    createdAt: prompt.createdAt,
                    periodStartedOn: dateOnly(
                      periodById[prompt.periodLogId]!.startedOn,
                    ),
                  ),
            ]
          : const [],
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

    final periodIdByStart = <DateTime, int>{};
    for (final log in backup.periodLogs) {
      final saved = await _periods.upsertPeriod(
        startedOn: log.startedOn,
        endedOn: log.endedOn,
        source: log.source,
        startSource: log.startSource,
        startConfidence: log.startConfidence,
        endStatus: log.endStatus,
        endSource: log.endSource,
        endConfidence: log.endConfidence,
        roughDurationBucket: log.roughDurationBucket,
      );
      periodIdByStart[log.startedOn] = saved.id;
    }

    for (final prompt in backup.periodEndPrompts) {
      final remapStart = prompt.periodStartedOn;
      final periodId = remapStart == null
          ? prompt.periodLogId
          : periodIdByStart[dateOnly(remapStart)];
      if (periodId == null) continue;

      final shown = await _periodEndPrompts.recordShown(
        periodLogId: periodId,
        shownOn: prompt.shownOn,
      );
      if (prompt.response != null && prompt.respondedOn != null) {
        await _periodEndPrompts.recordResponse(
          promptId: shown.id,
          response: prompt.response!,
          respondedOn: prompt.respondedOn!,
        );
      }
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
