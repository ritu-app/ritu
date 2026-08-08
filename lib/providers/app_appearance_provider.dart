import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/app_appearance.dart';

const _appearancePrefsKey = 'app_appearance';

final appAppearanceProvider =
    AsyncNotifierProvider<AppAppearanceNotifier, AppAppearance>(
  AppAppearanceNotifier.new,
);

class AppAppearanceNotifier extends AsyncNotifier<AppAppearance> {
  @override
  Future<AppAppearance> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppAppearance.fromStorage(prefs.getString(_appearancePrefsKey));
  }

  Future<void> setAppearance(AppAppearance appearance) async {
    state = AsyncData(appearance);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appearancePrefsKey, appearance.storageValue);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appearancePrefsKey);
    // Only write state once this notifier has finished its first build.
    // Calling clear during AsyncLoading (e.g. Delete Data before Appearance
    // was ever opened) would otherwise throw and abort the wipe flow.
    if (!state.isLoading) {
      state = const AsyncData(AppAppearance.system);
    }
  }

  /// Clears the persisted preference without requiring the notifier to be ready.
  static Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appearancePrefsKey);
  }
}
