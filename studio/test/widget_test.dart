import 'package:flutter_test/flutter_test.dart';
import 'package:ritu_studio/main.dart';

Future<void> _pumpStudio(WidgetTester tester) async {
  await tester.pumpWidget(const CycleStudioApp());
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('StudioScope mounts', (tester) async {
    await _pumpStudio(tester);

    expect(find.text('Cycle Studio'), findsOneWidget);
  });
}
