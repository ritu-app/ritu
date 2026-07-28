import 'package:drift/drift.dart';

import '../../local/app_database.dart';
import '../symptom_repository.dart';

class DriftSymptomRepository implements SymptomRepository {
  DriftSymptomRepository(this._db);

  final AppDatabase _db;

  CustomSymptom _mapSymptom(CustomSymptomRow row) {
    return CustomSymptom(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<List<CustomSymptom>> getAll() async {
    final rows = await (_db.select(_db.customSymptoms)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_mapSymptom).toList();
  }

  @override
  Stream<List<CustomSymptom>> watchAll() {
    return (_db.select(_db.customSymptoms)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapSymptom).toList());
  }

  @override
  Future<CustomSymptom?> addSymptom(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final existing = await getAll();
    final match = existing.where(
      (s) => s.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (match.isNotEmpty) return match.first;

    final now = DateTime.now();
    final id = await _db.into(_db.customSymptoms).insert(
          CustomSymptomsCompanion.insert(
            name: trimmed,
            createdAt: now,
          ),
        );
    return CustomSymptom(id: id, name: trimmed, createdAt: now);
  }

  @override
  Future<void> deleteSymptom(int id) async {
    await (_db.delete(_db.customSymptoms)..where((t) => t.id.equals(id))).go();
  }
}
