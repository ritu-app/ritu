import 'package:drift/drift.dart';

/// `dart:ffi` (and therefore `NativeDatabase`) isn't available on web, so
/// there's no in-memory sqlite backend to fall back to here. Callers should
/// check `kIsWeb` before using [AppDatabase.memory] rather than relying on
/// this to fail gracefully.
QueryExecutor createMemoryExecutor() {
  throw UnsupportedError(
    'AppDatabase.memory() (native FFI sqlite) is not supported on web.',
  );
}
