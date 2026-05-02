// lib/main.dart

import 'package:flutter/material.dart';
import 'package:nobochitro/widgets/app_theme.dart'; // Make sure your app name matches here
import 'package:nobochitro/screens/dashboard_screen.dart';

void main() {
  runApp(const PhotographyApp());
}

class PhotographyApp extends StatefulWidget {
  const PhotographyApp({Key? key}) : super(key: key);

  @override
  State<PhotographyApp> createState() => _PhotographyAppState();
}

class _PhotographyAppState extends State<PhotographyApp> {
  // To manually test, change this to ThemeMode.light or ThemeMode.dark
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isOn) {
    setState(() {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobochitro',
      // Light Theme
      theme: AppTheme.lightTheme,
      // Dark Theme
      darkTheme: AppTheme.darkTheme,
      // System Theme flow
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}