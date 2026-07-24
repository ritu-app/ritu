import 'package:flutter/material.dart';

import '../data/repositories/profile_repository.dart';

/// Provides [ProfileRepository] and app-level actions to the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.profileRepository,
    required this.restartApp,
    required super.child,
  });

  final ProfileRepository profileRepository;

  /// Remounts the root bootstrap (e.g. after wiping local data).
  final VoidCallback restartApp;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  static ProfileRepository profiles(BuildContext context) {
    return of(context).profileRepository;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return profileRepository != oldWidget.profileRepository ||
        restartApp != oldWidget.restartApp;
  }
}
