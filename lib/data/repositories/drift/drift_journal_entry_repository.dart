import 'package:drift/drift.dart';

import '../../../core/date_format.dart';
import '../../local/app_database.dart';
import '../journal_entry_repository.dart';

class DriftJournalEntryRepository implements JournalEntryRepository {
  DriftJournalEntryRepository(this._db);

  final AppDatabase _db;

  JournalEntry _mapEntry(JournalEntryRow row) {
    return JournalEntry(
      id: row.id,
      loggedOn: dateOnly(row.loggedOn),
      body: row.body,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<JournalEntry?> getByDate(DateTime date) async {
    final day = dateOnly(date);
    final row = await (_db.select(
      _db.journalEntries,
    )..where((t) => t.loggedOn.equals(day))).getSingleOrNull();
    if (row == null) return null;
    return _mapEntry(row);
  }

  @override
  Stream<JournalEntry?> watchByDate(DateTime date) {
    final day = dateOnly(date);
    return (_db.select(_db.journalEntries)
          ..where((t) => t.loggedOn.equals(day)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapEntry(row));
  }

  @override
  Future<List<JournalEntry>> getAll() async {
    final rows = await (_db.select(_db.journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedOn)]))
        .get();
    return rows.map(_mapEntry).toList();
  }

  @override
  Future<List<JournalEntry>> getPastEntries({
    required DateTime before,
    int limit = 50,
  }) async {
    final cutoff = dateOnly(before);
    final rows =
        await (_db.select(_db.journalEntries)
              ..where((t) => t.loggedOn.isSmallerThanValue(cutoff))
              ..orderBy([
                (t) => OrderingTerm.desc(t.loggedOn),
              ])
              ..limit(limit))
            .get();
    return rows.map(_mapEntry).toList();
  }

  @override
  Stream<List<JournalEntry>> watchPastEntries({
    required DateTime before,
    int limit = 50,
  }) {
    final cutoff = dateOnly(before);
    return (_db.select(_db.journalEntries)
          ..where((t) => t.loggedOn.isSmallerThanValue(cutoff))
          ..orderBy([
            (t) => OrderingTerm.desc(t.loggedOn),
          ])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Future<JournalEntry> upsert({
    required DateTime loggedOn,
    required String body,
  }) async {
    final day = dateOnly(loggedOn);
    final now = DateTime.now();
    final trimmed = body.trim();

    final existing = await (_db.select(
      _db.journalEntries,
    )..where((t) => t.loggedOn.equals(day))).getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.journalEntries).insert(
            JournalEntriesCompanion.insert(
              loggedOn: day,
              body: trimmed,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.journalEntries)
            ..where((t) => t.id.equals(existing.id)))
          .write(
            JournalEntriesCompanion(
              body: Value(trimmed),
              updatedAt: Value(now),
            ),
          );
    }

    return (await getByDate(day))!;
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.journalEntries)..where((t) => t.id.equals(id))).go();
  }
}
