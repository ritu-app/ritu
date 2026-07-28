import '../models/custom_symptom.dart';

export '../models/custom_symptom.dart';

/// Manages user-defined body signals / symptoms shown in the daily log.
abstract class SymptomRepository {
  Future<List<CustomSymptom>> getAll();

  Stream<List<CustomSymptom>> watchAll();

  /// Adds a new symptom. Returns the existing entry (no duplicate row) if a
  /// symptom with the same name (case-insensitive) already exists.
  Future<CustomSymptom?> addSymptom(String name);

  Future<void> deleteSymptom(int id);
}
