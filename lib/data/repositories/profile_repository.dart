import 'package:drift/drift.dart';

import '../local/app_database.dart';

class Profile {
  const Profile({
    required this.displayName,
    required this.createdAt,
    this.onboardingCompletedAt,
    this.typicalPeriodDays,
  });

  final String displayName;
  final DateTime createdAt;
  final DateTime? onboardingCompletedAt;
  final int? typicalPeriodDays;

  bool get hasCompletedOnboarding => onboardingCompletedAt != null;

  factory Profile.fromRow(ProfileRow row) {
    return Profile(
      displayName: row.displayName,
      createdAt: row.createdAt,
      onboardingCompletedAt: row.onboardingCompletedAt,
      typicalPeriodDays: row.typicalPeriodDays,
    );
  }
}

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  static const int _singletonId = 1;

  Future<Profile?> getProfile() async {
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    if (row == null) return null;
    return Profile.fromRow(row);
  }

  /// Creates or updates the local profile display name.
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

  /// Wipes all local tables (profile, period logs, …).
  Future<void> clearAllData() => _db.clearAllData();
}
