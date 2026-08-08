import '../profile_repository.dart';
import 'memory_ritu_store.dart';

class MemoryProfileRepository implements ProfileRepository {
  MemoryProfileRepository(this._store);

  final MemoryRituStore _store;

  @override
  Future<Profile?> getProfile() async => _store.profile;

  @override
  Stream<Profile?> watchProfile() async* {
    yield _store.profile;
    await for (final _ in _store.profileChanges) {
      yield _store.profile;
    }
  }

  @override
  Future<Profile> upsertDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(displayName, 'displayName', 'must not be empty');
    }

    final existing = _store.profile;
    final now = DateTime.now();
    _store.profile = Profile(
      displayName: trimmed,
      createdAt: existing?.createdAt ?? now,
      onboardingCompletedAt: existing?.onboardingCompletedAt,
      typicalPeriodDays: existing?.typicalPeriodDays,
    );
    _store.notifyProfile();
    return _store.profile!;
  }

  @override
  Future<Profile> setTypicalPeriodDays(int? days) async {
    final existing = _store.profile;
    if (existing == null) {
      throw StateError('Cannot set typical period days without a profile');
    }
    _store.profile = Profile(
      displayName: existing.displayName,
      createdAt: existing.createdAt,
      onboardingCompletedAt: existing.onboardingCompletedAt,
      typicalPeriodDays: days,
    );
    _store.notifyProfile();
    return _store.profile!;
  }

  @override
  Future<Profile> markOnboardingCompleted() async {
    final existing = _store.profile;
    if (existing == null) {
      throw StateError('Cannot complete onboarding without a profile');
    }
    _store.profile = Profile(
      displayName: existing.displayName,
      createdAt: existing.createdAt,
      onboardingCompletedAt: DateTime.now(),
      typicalPeriodDays: existing.typicalPeriodDays,
    );
    _store.notifyProfile();
    return _store.profile!;
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
    _store.profile = Profile(
      displayName: trimmed,
      createdAt: profile.createdAt,
      onboardingCompletedAt: profile.onboardingCompletedAt,
      typicalPeriodDays: profile.typicalPeriodDays,
    );
    _store.notifyProfile();
    return _store.profile!;
  }

  @override
  Future<void> clearAllData() async {
    _store.clearAll();
  }
}
