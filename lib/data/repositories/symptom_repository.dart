import 'package:drift/drift.dart';

import '../local/app_database.dart';

class CustomSymptom {
  const CustomSymptom({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final int id;
  final String name;
  final DateTime createdAt;

  factory CustomSymptom.fromRow(CustomSymptomRow row) {
    return CustomSymptom(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
    );
  }
}

/// Manages user-defined body signals / symptoms shown in the daily log.
class SymptomRepository {
  SymptomRepository(this._db);

  final AppDatabase _db;

  Future<List<CustomSymptom>> getAll() async {
    final rows = await (_db.select(_db.customSymptoms)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(CustomSymptom.fromRow).toList();
  }

  /// Adds a new symptom. Returns the existing entry (no duplicate row) if a
  /// symptom with the same name (case-insensitive) already exists.
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

  Future<void> deleteSymptom(int id) async {
    await (_db.delete(_db.customSymptoms)..where((t) => t.id.equals(id))).go();
  }
}
