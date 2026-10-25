import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ritu/app/ritu_app.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/repositories/drift/drift_profile_repository.dart';
import 'package:ritu/providers/package_info_provider.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Settings footer shows the installed app version', (
    tester,
  ) async {
    final profiles = DriftProfileRepository(database);
    await profiles.upsertDisplayName('Maya');
    await profiles.markOnboardingCompleted();

    await tester.pumpWidget(
      createRituApp(
        database: database,
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'Ritu',
              packageName: 'care.ritu.app',
              version: '0.1.0',
              buildNumber: '13',
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Version 0.1.0'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Version 0.1.0'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
  });
}
