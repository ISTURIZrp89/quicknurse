import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QuickNurseApp());
}

class QuickNurseApp extends StatefulWidget {
  const QuickNurseApp({super.key});

  @override
  State<QuickNurseApp> createState() => _QuickNurseAppState();
}

class _QuickNurseAppState extends State<QuickNurseApp> {
  bool _darkMode = true;

  void _toggleTheme() {
    setState(() => _darkMode = !_darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickNurse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onToggleTheme: _toggleTheme, isDark: _darkMode),
    );
  }
}
