import 'package:flutter/material.dart';
import 'package:nobochitro/screens/dashboard_screen.dart';
import 'package:nobochitro/screens/splash_screen.dart';
import 'package:nobochitro/support_hub/support_hub.dart';

void main() {
  runApp(const PhotographyApp());
}

class PhotographyApp extends StatefulWidget {
  const PhotographyApp({Key? key}) : super(key: key);

  @override
  State<PhotographyApp> createState() => _PhotographyAppState();
}

class _PhotographyAppState extends State<PhotographyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  // এই ভেরিয়েবলটি কন্ট্রোল করবে সাপোর্ট হাব কখন দেখাবে
  bool _showSupportHub = false;

  void toggleTheme(bool isOn) {
    setState(() {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // স্প্ল্যাশ স্ক্রিন শেষ হলে এই ফাংশনটি কল হবে
  void onAppReady() {
    setState(() {
      _showSupportHub = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobochitro',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF008080),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryAccent = isDark ? const Color(0xFFD4AF37) : const Color(0xFF008080);

        return Scaffold(
          body: child,
          // কেবল মাত্র যখন _showSupportHub true হবে, তখনই এটি দেখাবে
          floatingActionButton: _showSupportHub
              ? SupportHub(primaryAccent: primaryAccent)
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },

      // SplashScreen এ onAppReady ফাংশনটি পাস করে দিন
      home: SplashScreen(
        onThemeChanged: toggleTheme,
        onAppReady: onAppReady,
      ),
    );
  }
}