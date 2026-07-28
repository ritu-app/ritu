import '../models/profile.dart';

export '../models/profile.dart';

/// Persistence for the local singleton profile.
abstract class ProfileRepository {
  Future<Profile?> getProfile();

  Stream<Profile?> watchProfile();

  /// Creates or updates the local profile display name.
  Future<Profile> upsertDisplayName(String displayName);

  Future<Profile> setTypicalPeriodDays(int? days);

  Future<Profile> markOnboardingCompleted();

  /// Wipes all local tables (profile, period logs, …).
  Future<void> clearAllData();
}
