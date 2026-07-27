import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'memory_executor.dart';
import 'tables/custom_symptoms.dart';
import 'tables/daily_logs.dart';
import 'tables/period_logs.dart';
import 'tables/profiles.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Profiles, PeriodLogs, CustomSymptoms, DailyLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for widget/unit tests. Native platforms only — see
  /// `memory_executor.dart`.
  AppDatabase.memory() : super(createMemoryExecutor());

  @override
  int get schemaVersion => 4;

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
