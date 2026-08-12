import 'package:drift/drift.dart';

/// Home "Still on your period?" prompt history for a period episode.
@DataClassName('PeriodEndPromptRow')
class PeriodEndPrompts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get periodLogId => integer()();

  DateTimeColumn get shownOn => dateTime()();

  /// `still_going`, `ended`, or `dismissed`.
  TextColumn get response => text().nullable()();

  DateTimeColumn get respondedOn => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}
