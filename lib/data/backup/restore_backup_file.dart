import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// A JSON file the user chose while restoring a backup.
class RestoreBackupFile {
  const RestoreBackupFile({
    required this.name,
    required this.sizeBytes,
    required this.contents,
  });

  final String name;
  final int sizeBytes;
  final String contents;
}

/// Opens the system file picker for a `.json` backup.
///
/// Returns null when the user dismisses the picker.
Future<RestoreBackupFile?> pickRestoreBackupFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;

  final file = result.files.single;
  final String raw;
  if (file.bytes != null) {
    raw = utf8.decode(file.bytes!);
  } else if (file.path != null) {
    raw = await File(file.path!).readAsString();
  } else {
    throw const FormatException('Could not read the selected file');
  }

  return RestoreBackupFile(
    name: file.name,
    sizeBytes: file.size,
    contents: raw,
  );
}

/// Compact size label, matching the restore screen (`184 KB`).
String formatBackupFileSize(int bytes) {
  if (bytes < 0) return '0 B';
  if (bytes < 1024) return '$bytes B';
  final kilobytes = bytes / 1024;
  if (kilobytes < 1024) return '${kilobytes.round()} KB';
  final megabytes = kilobytes / 1024;
  final rounded = megabytes >= 10
      ? megabytes.round().toString()
      : megabytes.toStringAsFixed(1);
  return '$rounded MB';
}
