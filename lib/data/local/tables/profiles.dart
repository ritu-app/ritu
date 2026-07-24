import 'package:drift/drift.dart';

/// Single-row local user profile (id is always 1).
@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get displayName => text().withLength(min: 1, max: 80)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get onboardingCompletedAt => dateTime().nullable()();

  /// Typical bleed length in days (e.g. 3, 5, 7). Null means "Varies".
  IntColumn get typicalPeriodDays => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
