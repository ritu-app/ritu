/// Saved appearance. The app applies it as the theme mode.
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
