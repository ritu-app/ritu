import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_format.dart';

/// Calendar "today" for cycle math and daily-log lookups.
///
/// Defaults to the real clock. Cycle Studio overrides this with a chosen date.
final simulatedTodayProvider = Provider<DateTime>(
  (ref) => dateOnly(DateTime.now()),
);
