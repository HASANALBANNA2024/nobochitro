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
  ThemeMode _themeMode = ThemeMode.dark; // ডিফল্ট লাইট মোড

  void toggleTheme(bool isOn) {
    setState(() {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobochitro',
      theme: ThemeData(brightness: Brightness.light, primaryColor: Colors.teal),
      darkTheme: ThemeData(brightness: Brightness.dark, primaryColor: const Color(0xFFD4AF37)),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      // toggleTheme ফাংশনটি ড্যাশবোর্ডে পাস করা হলো
      home: DashboardScreen(onThemeChanged: toggleTheme),
    );
  }
}