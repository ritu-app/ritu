import 'dart:async';

/// Bridges daily-reminder notification taps to [HomeScreen].
///
/// Uses a pending flag (cold start before Home is mounted) plus a broadcast
/// stream (tap while the app is already running).
class DailyLogNotificationNavigation {
  DailyLogNotificationNavigation._();

  static bool _pending = false;
  static final _controller = StreamController<void>.broadcast();

  static Stream<void> get requests => _controller.stream;

  static void requestOpen() {
    _pending = true;
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  /// Returns whether an open was requested, and clears the flag.
  static bool takePending() {
    final pending = _pending;
    _pending = false;
    return pending;
  }
}
