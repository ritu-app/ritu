import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wall-clock "now" for time-of-day greetings.
///
/// Defaults to [DateTime.now]. Cycle Studio and Widgetbook override this.
final simulatedClockProvider = Provider<DateTime>((ref) => DateTime.now());
