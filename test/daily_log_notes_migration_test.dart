import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/repositories/drift/drift_journal_entry_repository.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens a database at schema v5 (with `daily_logs.notes`), seeds rows, then
/// upgrades through [AppDatabase]'s migration to verify notes land in journal.
void main() {
  test('v6 migrates daily_logs.notes into journal_entries', () async {
    final now = DateTime(2026, 8, 1, 12);
    final dayWithNote = DateTime(2026, 7, 30);
    final dayWithBoth = DateTime(2026, 7, 31);
    final dayWithoutNote = DateTime(2026, 7, 29);

    int unix(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;

    // Bootstrap a v5-shaped schema with the notes column still present.
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
  notes TEXT NULL,
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
    sqlite.execute(
      'INSERT INTO daily_logs (logged_on, notes, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      [unix(dayWithNote), '  Migrated note  ', unix(now), unix(now)],
    );
    sqlite.execute(
      'INSERT INTO daily_logs (logged_on, notes, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      [unix(dayWithBoth), 'Orphaned note', unix(now), unix(now)],
    );
    sqlite.execute(
      'INSERT INTO daily_logs (logged_on, notes, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      [unix(dayWithoutNote), null, unix(now), unix(now)],
    );
    sqlite.execute(
      'INSERT INTO journal_entries (logged_on, body, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      [unix(dayWithBoth), 'Existing journal', unix(now), unix(now)],
    );
    sqlite.execute('PRAGMA user_version = 5');

    final db = AppDatabase(NativeDatabase.opened(sqlite));
    // Touch the database so onUpgrade runs.
    await db.customSelect('SELECT 1').get();

    final journal = DriftJournalEntryRepository(db);
    final migrated = await journal.getByDate(dayWithNote);
    expect(migrated?.body, 'Migrated note');
    expect(dateOnly(migrated!.loggedOn), dateOnly(dayWithNote));

    // Existing journal row wins over daily_logs.notes for the same day.
    final kept = await journal.getByDate(dayWithBoth);
    expect(kept?.body, 'Existing journal');

    expect(await journal.getByDate(dayWithoutNote), isNull);

    // Column should be gone after alterTable.
    final columns = await db.customSelect('PRAGMA table_info(daily_logs)').get();
    expect(
      columns.map((c) => c.read<String>('name')),
      isNot(contains('notes')),
    );

    await db.close();
  });
}
