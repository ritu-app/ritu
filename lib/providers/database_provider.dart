import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';

/// Shared Drift database for the app lifetime. Override with
/// [databaseProvider.overrideWithValue] in tests and Widgetbook.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
