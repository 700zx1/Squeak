import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squeak/main.dart';
import 'package:squeak/screens/home_screen.dart';
import 'package:squeak/screens/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dark Mode Screenshots', () {
    testWidgets('Home Screen (Dark Mode)', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: HomeScreen(
          isDarkMode: true,
          onThemeChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();
      await takeScreenshot(tester, 'screenshots/home_dark.png');
    });

    testWidgets('Settings Screen (Dark Mode)', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: SettingsPage(
          isDarkMode: true,
          onThemeChanged: (_) {},
          ttsSpeed: 1.0,
          onTtsSpeedChanged: (_) {},
          ttsVoice: 'Default',
          onTtsVoiceChanged: (_) {},
          ttsEngine: 'Default',
          onTtsEngineChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();
      await takeScreenshot(tester, 'screenshots/settings_dark.png');
    });

    testWidgets('Splash/Loading Screen (Dark Mode)', (WidgetTester tester) async {
      // Simulate a splash/loading screen
      await tester.pumpWidget(MaterialApp(
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
      ));
      await tester.pumpAndSettle();
      await takeScreenshot(tester, 'screenshots/splash_dark.png');
    });
  });
}

Future<void> takeScreenshot(WidgetTester tester, String path) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
  final pixels = await binding.takeScreenshot();
  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsBytes(pixels);
}
