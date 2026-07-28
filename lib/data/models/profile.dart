/// Local user profile (singleton row in SQLite).
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
}
