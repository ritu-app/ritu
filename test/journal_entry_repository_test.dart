import 'package:flutter_test/flutter_test.dart';

import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/repositories/drift/drift_journal_entry_repository.dart';
import 'package:ritu/data/repositories/journal_entry_repository.dart';

void main() {
  late AppDatabase database;
  late JournalEntryRepository repository;

  setUp(() {
    database = AppDatabase.memory();
    repository = DriftJournalEntryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('upsert creates and updates today entry', () async {
    final today = DateTime.now();
    final created = await repository.upsert(
      loggedOn: today,
      body: 'First reflection',
    );
    expect(created.body, 'First reflection');

    final updated = await repository.upsert(
      loggedOn: today,
      body: 'Updated reflection',
    );
    expect(updated.id, created.id);
    expect(updated.body, 'Updated reflection');
    final fetched = await repository.getByDate(today);
    expect(fetched?.body, 'Updated reflection');
    expect(fetched?.id, created.id);
  });

  test('past entries exclude today and sort newest first', () async {
    final today = dateOnly(DateTime.now());
    await repository.upsert(loggedOn: today, body: 'Today');
    await repository.upsert(
      loggedOn: today.subtract(const Duration(days: 2)),
      body: 'Older',
    );
    await repository.upsert(
      loggedOn: today.subtract(const Duration(days: 1)),
      body: 'Yesterday',
    );

    final past = await repository.getPastEntries(before: today);
    expect(past, hasLength(2));
    expect(past.first.body, 'Yesterday');
    expect(past.last.body, 'Older');
  });

  test('delete removes entry', () async {
    final entry = await repository.upsert(
      loggedOn: DateTime.now().subtract(const Duration(days: 3)),
      body: 'To delete',
    );
    await repository.delete(entry.id);
    expect(
      await repository.getPastEntries(before: DateTime.now()),
      isEmpty,
    );
  });
}
