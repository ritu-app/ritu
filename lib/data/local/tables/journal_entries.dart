import 'package:drift/drift.dart';

/// One free-text reflection per calendar day (Journal tab and daily-log notes).
@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Calendar date the reflection is for (time component ignored).
  DateTimeColumn get loggedOn => dateTime()();

  TextColumn get body => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {loggedOn},
  ];
}
