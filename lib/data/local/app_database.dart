import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/date_format.dart';
import '../models/period_log.dart';
import 'memory_executor.dart';
import 'tables/custom_symptoms.dart';
import 'tables/daily_logs.dart';
import 'tables/journal_entries.dart';
import 'tables/period_end_prompts.dart';
import 'tables/period_logs.dart';
import 'tables/profiles.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Profiles,
  PeriodLogs,
  PeriodEndPrompts,
  CustomSymptoms,
  DailyLogs,
  JournalEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for widget/unit tests. Native platforms only — see
  /// `memory_executor.dart`.
  AppDatabase.memory() : super(createMemoryExecutor());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(profiles, profiles.typicalPeriodDays);
            await m.createTable(periodLogs);
          }
          if (from < 3) {
            await m.createTable(customSymptoms);
          }
          if (from < 4) {
            await m.createTable(dailyLogs);
          }
          if (from < 5) {
            await m.createTable(journalEntries);
          }
          if (from < 6) {
            // Notes used to live on daily_logs; fold them into journal_entries
            // (canonical home for free-text reflections), then drop the column.
            final noteRows = await customSelect(
              'SELECT logged_on, notes, created_at, updated_at '
              'FROM daily_logs '
              'WHERE notes IS NOT NULL AND TRIM(notes) != \'\'',
            ).get();
            for (final row in noteRows) {
              final day = dateOnly(row.read<DateTime>('logged_on'));
              final existing = await (select(journalEntries)
                    ..where((t) => t.loggedOn.equals(day)))
                  .getSingleOrNull();
              if (existing != null) continue;
              await into(journalEntries).insert(
                JournalEntriesCompanion.insert(
                  loggedOn: day,
                  body: row.read<String>('notes').trim(),
                  createdAt: row.read<DateTime>('created_at'),
                  updatedAt: row.read<DateTime>('updated_at'),
                ),
              );
            }
            await m.alterTable(TableMigration(dailyLogs));
          }
          if (from < 7) {
            await m.addColumn(periodLogs, periodLogs.startSource);
            await m.addColumn(periodLogs, periodLogs.startConfidence);
            await m.addColumn(periodLogs, periodLogs.endStatus);
            await m.addColumn(periodLogs, periodLogs.endSource);
            await m.addColumn(periodLogs, periodLogs.endConfidence);
            await m.addColumn(periodLogs, periodLogs.roughDurationBucket);
            await m.createTable(periodEndPrompts);

            final rows = await select(periodLogs).get();
            for (final row in rows) {
              final endedOn =
                  row.endedOn == null ? null : dateOnly(row.endedOn!);
              final meta = PeriodLogMetadata.fromLegacySource(
                row.source,
                startedOn: dateOnly(row.startedOn),
                endedOn: endedOn,
              );
              await (update(periodLogs)..where((t) => t.id.equals(row.id)))
                  .write(
                PeriodLogsCompanion(
                  startSource: Value(meta.startSource),
                  startConfidence: Value(meta.startConfidence),
                  endStatus: Value(meta.endStatus),
                  endSource: Value(meta.endSource),
                  endConfidence: Value(meta.endConfidence),
                  roughDurationBucket: Value(meta.roughDurationBucket),
                ),
              );
            }
          }
        },
      );

  /// Deletes every row in every table. Safe to call as new tables are added.
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'ritu',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
