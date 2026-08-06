import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_format.dart';
import '../data/repositories/journal_entry_repository.dart';
import 'repository_providers.dart';

final todayJournalEntryProvider = StreamProvider<JournalEntry?>((ref) {
  return ref
      .watch(journalEntryRepositoryProvider)
      .watchByDate(DateTime.now());
});

final journalEntryByDateProvider =
    StreamProvider.family<JournalEntry?, DateTime>((ref, date) {
  return ref
      .watch(journalEntryRepositoryProvider)
      .watchByDate(dateOnly(date));
});

final pastJournalEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  return ref.watch(journalEntryRepositoryProvider).watchPastEntries(
        before: dateOnly(DateTime.now()),
        limit: 50,
      );
});
