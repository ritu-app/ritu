import '../symptom_repository.dart';
import 'memory_ritu_store.dart';

class MemorySymptomRepository implements SymptomRepository {
  MemorySymptomRepository(this._store);

  final MemoryRituStore _store;

  List<CustomSymptom> get _sorted =>
      List<CustomSymptom>.from(_store.symptoms)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<List<CustomSymptom>> getAll() async => _sorted;

  @override
  Stream<List<CustomSymptom>> watchAll() async* {
    yield await getAll();
    await for (final _ in _store.symptomsChanges) {
      yield await getAll();
    }
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
    final symptom = CustomSymptom(
      id: _store.nextSymptomId++,
      name: trimmed,
      createdAt: now,
    );
    _store.symptoms.add(symptom);
    _store.notifySymptoms();
    return symptom;
  }

  @override
  Future<void> deleteSymptom(int id) async {
    _store.symptoms.removeWhere((s) => s.id == id);
    _store.notifySymptoms();
  }
}
