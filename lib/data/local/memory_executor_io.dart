import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Native (VM/AOT) platforms have `dart:ffi`, so they can use drift's
/// FFI-backed sqlite bindings directly.
QueryExecutor createMemoryExecutor() => NativeDatabase.memory();
