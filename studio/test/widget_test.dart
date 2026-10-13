import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu_studio/main.dart';

Future<void> _pumpStudio(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1512, 982);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const CycleStudioApp());
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('Studio shell shows the playground layout', (tester) async {
    await _pumpStudio(tester);

    expect(find.text('Cycle Studio'), findsOneWidget);
    expect(find.text('How this works'), findsOneWidget);
    expect(find.text('How Ritu got here'), findsOneWidget);
    expect(find.text('Reset scenario'), findsOneWidget);
    expect(find.text('Recent changes'), findsOneWidget);

    await tester.tap(find.text('Simulated date & time'));
    await tester.pump();

    expect(find.text('Time of day'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);

    await tester.ensureVisible(find.text('Scenario preset'));
    await tester.tap(find.text('Scenario preset'));
    await tester.pump();
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Variable cycle'), findsOneWidget);
    expect(find.text('New to Ritu (no cycles yet)'), findsOneWidget);

    await tester.ensureVisible(find.text('Cycle history'));
    await tester.tap(find.text('Cycle history'));
    await tester.pump();
    expect(find.text('Add cycle'), findsOneWidget);
    expect(find.textContaining('Current cycle'), findsOneWidget);

    await tester.ensureVisible(find.text('Logged data'));
    await tester.tap(find.text('Logged data'));
    await tester.pump();
    expect(find.text('Logged today'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('Occasional'), findsOneWidget);

    await tester.ensureVisible(find.text('Export scenario'));
    await tester.tap(find.text('Export scenario'));
    await tester.pump();
    expect(find.text('Scenario includes'), findsOneWidget);
    expect(find.text('6 completed cycles'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });

  testWidgets('editing cycle history switches the preset to Custom', (
    tester,
  ) async {
    await _pumpStudio(tester);

    await tester.ensureVisible(find.text('Cycle history'));
    await tester.tap(find.text('Cycle history'));
    await tester.pump();
    await tester.ensureVisible(find.text('Add cycle'));
    await tester.tap(find.text('Add cycle'));
    await tester.pump();

    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Regular cycle'), findsNothing);
  });
}
