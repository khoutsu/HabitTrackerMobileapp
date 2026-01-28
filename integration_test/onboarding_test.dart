import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/main_test.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows onboarding screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': false});
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Loop Habit Tracker!'), findsOneWidget);
  });

  testWidgets('shows main app screen when onboarding is completed', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('No habits yet!'), findsOneWidget);
  });
}
