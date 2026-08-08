import 'package:drift/drift.dart';

import '../../local/app_database.dart';
import '../profile_repository.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._db);

  final AppDatabase _db;

  static const int _singletonId = 1;

  Profile _mapProfile(ProfileRow row) {
    return Profile(
      displayName: row.displayName,
      createdAt: row.createdAt,
      onboardingCompletedAt: row.onboardingCompletedAt,
      typicalPeriodDays: row.typicalPeriodDays,
    );
  }

  @override
  Future<Profile?> getProfile() async {
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapProfile(row);
  }

  @override
  Stream<Profile?> watchProfile() {
    return (_db.select(_db.profiles)..where((t) => t.id.equals(_singletonId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapProfile(row));
  }

  @override
  Future<Profile> upsertDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(displayName, 'displayName', 'must not be empty');
    }

    final existing = await getProfile();
    final now = DateTime.now();

    await _db.into(_db.profiles).insertOnConflictUpdate(
          ProfilesCompanion.insert(
            id: const Value(_singletonId),
            displayName: trimmed,
            createdAt: existing?.createdAt ?? now,
            onboardingCompletedAt: Value(existing?.onboardingCompletedAt),
            typicalPeriodDays: Value(existing?.typicalPeriodDays),
          ),
        );

    return (await getProfile())!;
  }

  @override
  Future<Profile> setTypicalPeriodDays(int? days) async {
    final existing = await getProfile();
    if (existing == null) {
      throw StateError('Cannot set typical period days without a profile');
    }

    await (_db.update(_db.profiles)..where((t) => t.id.equals(_singletonId)))
        .write(
      ProfilesCompanion(typicalPeriodDays: Value(days)),
    );

    return (await getProfile())!;
  }

  @override
  Future<Profile> markOnboardingCompleted() async {
    final existing = await getProfile();
    if (existing == null) {
      throw StateError('Cannot complete onboarding without a profile');
    }

    await (_db.update(_db.profiles)..where((t) => t.id.equals(_singletonId)))
        .write(
      ProfilesCompanion(
        onboardingCompletedAt: Value(DateTime.now()),
      ),
    );

    return (await getProfile())!;
  }

  @override
  Future<Profile> restoreProfile(Profile profile) async {
    final trimmed = profile.displayName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        profile.displayName,
        'displayName',
        'must not be empty',
      );
    }

    await _db.into(_db.profiles).insertOnConflictUpdate(
          ProfilesCompanion.insert(
            id: const Value(_singletonId),
            displayName: trimmed,
            createdAt: profile.createdAt,
            onboardingCompletedAt: Value(profile.onboardingCompletedAt),
            typicalPeriodDays: Value(profile.typicalPeriodDays),
          ),
        );

    return (await getProfile())!;
  }

  @override
  Future<void> clearAllData() => _db.clearAllData();
}
