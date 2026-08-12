import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/models/period_log.dart';
import 'package:ritu/data/repositories/drift/drift_period_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v7 backfills period_logs metadata from legacy source', () async {
    final now = DateTime(2026, 8, 1, 12);
    int unix(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;

    final sqlite = sqlite3.openInMemory();
    sqlite.execute('''
CREATE TABLE profiles (
  id INTEGER NOT NULL PRIMARY KEY,
  display_name TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  onboarding_completed_at INTEGER NULL,
  typical_period_days INTEGER NULL
);
CREATE TABLE period_logs (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  started_on INTEGER NOT NULL,
  ended_on INTEGER NULL,
  source TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (started_on)
);
CREATE TABLE custom_symptoms (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL
);
CREATE TABLE daily_logs (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  logged_on INTEGER NOT NULL,
  flow_intensity TEXT NULL,
  cramp_intensity INTEGER NULL,
  moods TEXT NULL,
  energy_level TEXT NULL,
  sleep_quality TEXT NULL,
  wellbeing INTEGER NULL,
  symptoms TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (logged_on)
);
CREATE TABLE journal_entries (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  logged_on INTEGER NOT NULL,
  body TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (logged_on)
);
''');

    final onboardingLast = DateTime(2026, 7, 1);
    final manualPast = DateTime(2026, 6, 1);
    final calendarOpen = DateTime(2026, 8, 10);

    sqlite.execute(
      'INSERT INTO period_logs (started_on, ended_on, source, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        unix(onboardingLast),
        unix(DateTime(2026, 7, 5)),
        PeriodSources.onboardingLast,
        unix(now),
        unix(now),
      ],
    );
    sqlite.execute(
      'INSERT INTO period_logs (started_on, ended_on, source, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        unix(manualPast),
        unix(DateTime(2026, 6, 4)),
        PeriodSources.manual,
        unix(now),
        unix(now),
      ],
    );
    sqlite.execute(
      'INSERT INTO period_logs (started_on, ended_on, source, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        unix(calendarOpen),
        null,
        PeriodSources.calendar,
        unix(now),
        unix(now),
      ],
    );
    sqlite.execute('PRAGMA user_version = 6');

    final db = AppDatabase(NativeDatabase.opened(sqlite));
    await db.customSelect('SELECT 1').get();

    final periods = DriftPeriodRepository(db);
    final all = await periods.getAll();
    expect(all, hasLength(3));

    final last = all.firstWhere(
      (log) => dateOnly(log.startedOn) == dateOnly(onboardingLast),
    );
    expect(last.startSource, PeriodStartSources.onboardingLast);
    expect(last.startConfidence, PeriodStartConfidence.logged);
    expect(last.endStatus, PeriodEndStatus.estimated);
    expect(last.endSource, PeriodEndSources.onboardingEstimate);

    final manual = all.firstWhere(
      (log) => dateOnly(log.startedOn) == dateOnly(manualPast),
    );
    expect(manual.startSource, PeriodStartSources.periodHistory);
    expect(manual.endStatus, PeriodEndStatus.rough);
    expect(manual.endSource, PeriodEndSources.addPeriodRough);
    expect(manual.roughDurationBucket, RoughDurationBuckets.fourToFiveDays);

    final open = all.firstWhere(
      (log) => dateOnly(log.startedOn) == dateOnly(calendarOpen),
    );
    expect(open.endStatus, PeriodEndStatus.open);
    expect(open.startSource, PeriodStartSources.dailyLog);

    final promptColumns =
        await db.customSelect('PRAGMA table_info(period_end_prompts)').get();
    expect(promptColumns, isNotEmpty);

    await db.close();
  });
}
