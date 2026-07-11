import 'package:flutter_test/flutter_test.dart';
import 'package:prime_gaming_store/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(
      hasSeenOnboarding: false,
      isLoggedIn: false,
    ));
  });
}