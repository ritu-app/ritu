import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Version stamped into the installed app from `pubspec.yaml`.
///
/// `version` is the name (`0.1.0`). `buildNumber` is the `+` build (`13`).
/// A `flutter build --build-name` override is reflected here too.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});
