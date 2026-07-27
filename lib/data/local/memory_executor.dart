/// Conditionally exports the platform-appropriate in-memory `QueryExecutor`
/// factory.
///
/// This keeps the `dart:ffi`-dependent `package:drift/native.dart` import
/// out of `AppDatabase`'s unconditional import graph, so code that depends
/// on `AppDatabase` (e.g. the Widgetbook catalog) can still compile for web
/// even though `AppDatabase.memory()` itself can't run there.
library;

export 'memory_executor_web.dart'
    if (dart.library.io) 'memory_executor_io.dart';
