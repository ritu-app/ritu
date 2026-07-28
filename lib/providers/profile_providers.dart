import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/profile_repository.dart';
import 'repository_providers.dart';

/// Reactive profile stream — bootstrap routing and Settings read from here.
final profileProvider = StreamProvider<Profile?>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfile();
});
