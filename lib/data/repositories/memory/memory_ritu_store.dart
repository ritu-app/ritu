import 'dart:async';

import '../../models/daily_log_entry.dart';
import '../../models/custom_symptom.dart';
import '../../models/journal_entry.dart';
import '../../models/period_log.dart';
import '../../models/period_end_prompt.dart';
import '../../models/profile.dart';

/// In-memory backing store shared by [MemoryProfileRepository] and siblings.
///
/// Used by Widgetbook (including web) where Drift's FFI sqlite backend is
/// unavailable. Not intended for production persistence.
class MemoryRituStore {
  Profile? profile;
  final periods = <PeriodLog>[];
  final periodEndPrompts = <PeriodEndPrompt>[];
  final symptoms = <CustomSymptom>[];
  final dailyLogs = <DateTime, DailyLogEntry>{};
  final journalEntries = <DateTime, JournalEntry>{};

  int nextPeriodId = 1;
  int nextPeriodEndPromptId = 1;
  int nextSymptomId = 1;
  int nextDailyLogId = 1;
  int nextJournalEntryId = 1;

  final _profileTick = StreamController<void>.broadcast();
  final _periodsTick = StreamController<void>.broadcast();
  final _periodEndPromptsTick = StreamController<void>.broadcast();
  final _symptomsTick = StreamController<void>.broadcast();
  final _dailyLogsTick = StreamController<void>.broadcast();
  final _journalEntriesTick = StreamController<void>.broadcast();

  void notifyProfile() => _profileTick.add(null);
  void notifyPeriods() => _periodsTick.add(null);
  void notifyPeriodEndPrompts() => _periodEndPromptsTick.add(null);
  void notifySymptoms() => _symptomsTick.add(null);
  void notifyDailyLogs() => _dailyLogsTick.add(null);
  void notifyJournalEntries() => _journalEntriesTick.add(null);

  Stream<void> get profileChanges => _profileTick.stream;
  Stream<void> get periodsChanges => _periodsTick.stream;
  Stream<void> get periodEndPromptsChanges => _periodEndPromptsTick.stream;
  Stream<void> get symptomsChanges => _symptomsTick.stream;
  Stream<void> get dailyLogsChanges => _dailyLogsTick.stream;
  Stream<void> get journalEntriesChanges => _journalEntriesTick.stream;

  void clearAll() {
    profile = null;
    periods.clear();
    periodEndPrompts.clear();
    symptoms.clear();
    dailyLogs.clear();
    journalEntries.clear();
    nextPeriodId = 1;
    nextPeriodEndPromptId = 1;
    nextSymptomId = 1;
    nextDailyLogId = 1;
    nextJournalEntryId = 1;
    notifyProfile();
    notifyPeriods();
    notifyPeriodEndPrompts();
    notifySymptoms();
    notifyDailyLogs();
    notifyJournalEntries();
  }

  void dispose() {
    _profileTick.close();
    _periodsTick.close();
    _periodEndPromptsTick.close();
    _symptomsTick.close();
    _dailyLogsTick.close();
    _journalEntriesTick.close();
  }
}
