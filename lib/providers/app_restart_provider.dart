import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after wiping local data so [MaterialApp] remounts and returns to
/// onboarding. Profile invalidation alone is not enough once navigation has
/// replaced the bootstrap shell with [HomeScreen].
final appRestartProvider = StateProvider<int>((ref) => 0);
