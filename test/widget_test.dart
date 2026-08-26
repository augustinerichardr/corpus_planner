import 'package:flutter_test/flutter_test.dart';
import 'package:corpus_planner/main.dart';

void main() {
  testWidgets('CorpusPlannerApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CorpusPlannerApp());

    // Verify that CorpusPlannerApp renders successfully.
    expect(find.byType(CorpusPlannerApp), findsOneWidget);
  });
}
