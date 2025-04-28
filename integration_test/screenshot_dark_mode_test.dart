import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:squeak/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;

  testWidgets('Take dark mode screenshots', (WidgetTester tester) async {
    // Home Screen (Dark Mode)
    await tester.pumpWidget(const SqueakApp());
    await tester.pumpAndSettle();
    // Enable dark mode (simulate by tapping settings or by default)
    // If your app starts in light mode, you may need to tap a toggle
    // For now, assume dark mode is default or persisted
    await binding.takeScreenshot('screenshots/home_dark');

    // Tap the settings icon to open settings page
    final settingsIcon = find.byIcon(Icons.settings);
    expect(settingsIcon, findsOneWidget);
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('screenshots/settings_dark');

    // Splash/Loading Screen (simulate)
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: ThemeData.dark().primaryColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(radius: 40, child: Text('🐭', style: TextStyle(fontSize: 32))),
                SizedBox(height: 24),
                Text('Loading...', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('screenshots/splash_dark');
  });
}
