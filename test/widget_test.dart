import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luna_app/main.dart';

void main() {
  testWidgets('Splash screen shows Luna branding and CTA', (tester) async {
    await tester.pumpWidget(const LunaApp());
    await tester.pump();

    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('Onboarding completes into homepage', (tester) async {
    await tester.pumpWidget(const LunaApp());
    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Maya 👋'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('This look right'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip – I’ll build from today'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Maya ✨'), findsOneWidget);
    expect(find.text('days since last period'), findsOneWidget);
    expect(find.text('How are you feeling today?'), findsOneWidget);
    expect(find.text('Log today'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Cycle & Tracking'), findsOneWidget);
    expect(find.text('Daily Reminder'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Cycle calendar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cycle calendar'), findsOneWidget);
  });
}
