import '../models/journal_entry.dart';

export '../models/journal_entry.dart';

/// Free-text Journal reflections — one row per calendar day.
abstract class JournalEntryRepository {
  Future<JournalEntry?> getByDate(DateTime date);

  Stream<JournalEntry?> watchByDate(DateTime date);

  /// All journal entries (including today), newest [loggedOn] first.
  Future<List<JournalEntry>> getAll();

  /// Entries before [before] (exclusive), newest first.
  Future<List<JournalEntry>> getPastEntries({
    required DateTime before,
    int limit = 50,
  });

  Stream<List<JournalEntry>> watchPastEntries({
    required DateTime before,
    int limit = 50,
  });

  Future<JournalEntry> upsert({
    required DateTime loggedOn,
    required String body,
  });

  Future<void> delete(int id);
}
