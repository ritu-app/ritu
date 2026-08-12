import 'package:drift/drift.dart';

import '../../models/period_log.dart';

/// One row per period episode (start ± optional end).
@DataClassName('PeriodLogRow')
class PeriodLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Calendar date the period started (time component ignored).
  DateTimeColumn get startedOn => dateTime()();

  /// Inclusive last bleed day. Null = unknown / still open.
  DateTimeColumn get endedOn => dateTime().nullable()();

  /// Legacy provenance: onboarding_last, onboarding_past, calendar, settings,
  /// manual.
  TextColumn get source => text()();

  TextColumn get startSource => text().withDefault(
        const Constant(PeriodStartSources.periodHistory),
      )();

  TextColumn get startConfidence => text().withDefault(
        const Constant(PeriodStartConfidence.manual),
      )();

  TextColumn get endStatus => text().withDefault(
        const Constant(PeriodEndStatus.unknown),
      )();

  TextColumn get endSource => text().nullable()();

  TextColumn get endConfidence => text().nullable()();

  TextColumn get roughDurationBucket => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {startedOn},
      ];
}
