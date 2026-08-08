import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app/ritu_app.dart';
import 'services/daily_reminder_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(createRituApp());
  // With iOS UIScene / FlutterImplicitEngineDelegate, plugins are registered
  // in didInitializeImplicitFlutterEngine — after Dart main may already run.
  // Defer so local_notifications is available.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(DailyReminderNotifications.syncFromPrefs());
  });
}
