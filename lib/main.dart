import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SqueakApp());
}

class SqueakApp extends StatefulWidget {
  const SqueakApp({Key? key}) : super(key: key);

  @override
  State<SqueakApp> createState() => _SqueakAppState();
}

class _SqueakAppState extends State<SqueakApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squeak',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}
