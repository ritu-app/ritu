import 'package:ritu/data/repositories/daily_log_repository.dart';
import 'package:ritu/data/repositories/journal_entry_repository.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/data/repositories/profile_repository.dart';
import 'package:ritu/data/repositories/symptom_repository.dart';

/// In-memory repositories exposed to Cycle Studio controls for mutation.
class RituRepos {
  RituRepos(
    this.profiles,
    this.periods,
    this.symptoms,
    this.dailyLogs,
    this.journalEntries,
  );

  final ProfileRepository profiles;
  final PeriodRepository periods;
  final SymptomRepository symptoms;
  final DailyLogRepository dailyLogs;
  final JournalEntryRepository journalEntries;
}

Future<void> seedOnboardedProfile(
  RituRepos repos, {
  String name = 'Studio',
}) async {
  await repos.profiles.upsertDisplayName(name);
  await repos.profiles.markOnboardingCompleted();
  await repos.profiles.setTypicalPeriodDays(5);
}
