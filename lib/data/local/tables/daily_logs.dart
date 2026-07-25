import 'package:drift/drift.dart';

/// One row per calendar day logged from the Home "Log today" flow.
@DataClassName('DailyLogRow')
class DailyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Calendar date the entry is for (time component ignored).
  DateTimeColumn get loggedOn => dateTime()();

  /// none / spotting / light / medium / heavy. Null = not answered.
  TextColumn get flowIntensity => text().nullable()();

  /// 0-10 slider value. Null = not answered.
  IntColumn get crampIntensity => integer().nullable()();

  /// JSON-encoded list of selected mood labels.
  TextColumn get moods => text().nullable()();

  TextColumn get energyLevel => text().nullable()();
  TextColumn get sleepQuality => text().nullable()();

  /// 0-10 slider value. Null = not answered.
  IntColumn get wellbeing => integer().nullable()();

  /// JSON-encoded list of selected body signal labels (preset + custom).
  TextColumn get symptoms => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {loggedOn},
  ];
}
