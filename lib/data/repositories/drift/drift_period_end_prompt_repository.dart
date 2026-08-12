import 'package:drift/drift.dart';

import '../../../core/date_format.dart';
import '../../local/app_database.dart';
import '../period_end_prompt_repository.dart';

class DriftPeriodEndPromptRepository implements PeriodEndPromptRepository {
  DriftPeriodEndPromptRepository(this._db);

  final AppDatabase _db;

  PeriodEndPrompt _mapRow(PeriodEndPromptRow row) {
    return PeriodEndPrompt(
      id: row.id,
      periodLogId: row.periodLogId,
      shownOn: row.shownOn,
      response: row.response,
      respondedOn: row.respondedOn,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<PeriodEndPrompt> recordShown({
    required int periodLogId,
    required DateTime shownOn,
  }) async {
    final now = DateTime.now();
    final id = await _db.into(_db.periodEndPrompts).insert(
          PeriodEndPromptsCompanion.insert(
            periodLogId: periodLogId,
            shownOn: shownOn,
            createdAt: now,
          ),
        );
    final row = await (_db.select(_db.periodEndPrompts)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return _mapRow(row);
  }

  @override
  Future<PeriodEndPrompt> recordResponse({
    required int promptId,
    required String response,
    required DateTime respondedOn,
  }) async {
    await (_db.update(_db.periodEndPrompts)..where((t) => t.id.equals(promptId)))
        .write(
      PeriodEndPromptsCompanion(
        response: Value(response),
        respondedOn: Value(respondedOn),
      ),
    );
    final row = await (_db.select(_db.periodEndPrompts)
          ..where((t) => t.id.equals(promptId)))
        .getSingle();
    return _mapRow(row);
  }

  @override
  Future<PeriodEndPrompt?> getLatestForPeriod(int periodLogId) async {
    final row = await (_db.select(_db.periodEndPrompts)
          ..where((t) => t.periodLogId.equals(periodLogId))
          ..orderBy([(t) => OrderingTerm.desc(t.shownOn)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<List<PeriodEndPrompt>> getAll() async {
    final rows = await (_db.select(_db.periodEndPrompts)
          ..orderBy([(t) => OrderingTerm.desc(t.shownOn)]))
        .get();
    return rows.map(_mapRow).toList();
  }
}
