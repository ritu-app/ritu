import 'package:drift/drift.dart';

/// A user-defined body signal / symptom shown in the daily log.
@DataClassName('CustomSymptomRow')
class CustomSymptoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {name},
      ];
}
