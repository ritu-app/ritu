import 'package:drift/drift.dart';

/// One row per period episode (start ± optional end).
@DataClassName('PeriodLogRow')
class PeriodLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Calendar date the period started (time component ignored).
  DateTimeColumn get startedOn => dateTime()();

  /// Inclusive last bleed day. Null = unknown / still open.
  DateTimeColumn get endedOn => dateTime().nullable()();

  /// Where this row came from: onboarding_last, onboarding_past, calendar,
  /// settings, manual.
  TextColumn get source => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {startedOn},
      ];
}
