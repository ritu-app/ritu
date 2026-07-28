import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/profile_repository.dart';
import 'repository_providers.dart';

/// Profile used by the app bootstrap shell. A one-shot read for now; screens
/// still reload via `setState` until PR3 moves them to repository streams.
final profileProvider = FutureProvider<Profile?>((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});
