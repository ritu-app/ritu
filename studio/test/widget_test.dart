import 'package:flutter_test/flutter_test.dart';
import 'package:ritu_studio/main.dart';

void main() {
  testWidgets('StudioScope mounts', (tester) async {
    await tester.pumpWidget(const CycleStudioApp());
    await tester.pumpAndSettle();

    expect(find.text('Cycle Studio'), findsOneWidget);
  });
}
