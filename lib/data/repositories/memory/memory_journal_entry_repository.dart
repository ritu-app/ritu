import '../../../core/date_format.dart';
import '../journal_entry_repository.dart';
import 'memory_ritu_store.dart';

class MemoryJournalEntryRepository implements JournalEntryRepository {
  MemoryJournalEntryRepository(this._store);

  final MemoryRituStore _store;

  @override
  Future<JournalEntry?> getByDate(DateTime date) async {
    return _store.journalEntries[dateOnly(date)];
  }

  @override
  Stream<JournalEntry?> watchByDate(DateTime date) async* {
    final day = dateOnly(date);
    yield _store.journalEntries[day];
    await for (final _ in _store.journalEntriesChanges) {
      yield _store.journalEntries[day];
    }
  }

  @override
  Future<List<JournalEntry>> getPastEntries({
    required DateTime before,
    int limit = 50,
  }) async {
    final cutoff = dateOnly(before);
    final entries = _store.journalEntries.values
        .where((entry) => dateOnly(entry.loggedOn).isBefore(cutoff))
        .toList()
      ..sort((a, b) => b.loggedOn.compareTo(a.loggedOn));
    if (entries.length <= limit) return entries;
    return entries.sublist(0, limit);
  }

  @override
  Stream<List<JournalEntry>> watchPastEntries({
    required DateTime before,
    int limit = 50,
  }) async* {
    yield await getPastEntries(before: before, limit: limit);
    await for (final _ in _store.journalEntriesChanges) {
      yield await getPastEntries(before: before, limit: limit);
    }
  }

  @override
  Future<JournalEntry> upsert({
    required DateTime loggedOn,
    required String body,
  }) async {
    final day = dateOnly(loggedOn);
    final now = DateTime.now();
    final trimmed = body.trim();

    final existing = _store.journalEntries[day];
    if (existing == null) {
      final entry = JournalEntry(
        id: _store.nextJournalEntryId++,
        loggedOn: day,
        body: trimmed,
        createdAt: now,
        updatedAt: now,
      );
      _store.journalEntries[day] = entry;
    } else {
      _store.journalEntries[day] = JournalEntry(
        id: existing.id,
        loggedOn: day,
        body: trimmed,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    }

    _store.notifyJournalEntries();
    return _store.journalEntries[day]!;
  }

  @override
  Future<void> delete(int id) async {
    _store.journalEntries.removeWhere((_, entry) => entry.id == id);
    _store.notifyJournalEntries();
  }
}
