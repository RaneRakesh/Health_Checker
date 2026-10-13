import 'package:flutter_test/flutter_test.dart';
import 'package:health_assistant_app/app.dart';

void main() {
  testWidgets('Health Assistant App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthAssistantApp());
    await tester.pump();

    // Verify that the login screen renders by default
    expect(find.text('Health Assistant Login'), findsOneWidget);
  });
}
