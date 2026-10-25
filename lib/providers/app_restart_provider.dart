import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after wiping local data so [MaterialApp] remounts and returns to
/// onboarding. Profile invalidation alone is not enough once navigation has
/// replaced the bootstrap shell with [HomeScreen].
final appRestartProvider = StateProvider<int>((ref) => 0);

/// Holds the onboarding shell on screen after a backup import, so the
/// welcome-back step can finish before routing switches to Home.
final onboardingRestoreLockProvider = StateProvider<bool>((ref) => false);
