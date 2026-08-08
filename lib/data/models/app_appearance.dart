/// User preference for app chrome. Dark mode is not applied yet — the value
/// is persisted so a future theme implementation can honor it.
enum AppAppearance {
  system,
  light,
  dark;

  String get label => switch (this) {
    AppAppearance.system => 'System',
    AppAppearance.light => 'Light',
    AppAppearance.dark => 'Dark',
  };

  String get subtitle => switch (this) {
    AppAppearance.system => 'Matches your phone’s setting',
    AppAppearance.light => 'Always use light mode',
    AppAppearance.dark => 'Always use dark mode',
  };

  String get storageValue => name;

  static AppAppearance fromStorage(String? value) {
    return AppAppearance.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => AppAppearance.system,
    );
  }
}
