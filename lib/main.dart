import 'package:flutter/material.dart';
import 'package:nobochitro/screens/dashboard_screen.dart';
import 'package:nobochitro/support_hub/support_hub.dart'; // Ensure this path is correct

void main() {
  runApp(const PhotographyApp());
}

class PhotographyApp extends StatefulWidget {
  const PhotographyApp({Key? key}) : super(key: key);

  @override
  State<PhotographyApp> createState() => _PhotographyAppState();
}

class _PhotographyAppState extends State<PhotographyApp> {
  // Default theme mode set to dark
  ThemeMode _themeMode = ThemeMode.dark;

  // Function to toggle between light and dark themes
  void toggleTheme(bool isOn) {
    setState(() {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobochitro',
      // Light Theme configuration
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF008080), // Teal color for light mode
      ),
      // Dark Theme configuration
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37), // Gold color for dark mode
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,

      // GLOBAL BUILDER: This wraps all screens with the Support Hub
      builder: (context, child) {
        // Fetch current theme to pass the correct primary accent to SupportHub
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryAccent = isDark
            ? const Color(0xFFD4AF37)
            : const Color(0xFF008080);

        return Scaffold(
          // 'child' represents the current screen being displayed (e.g., DashboardScreen)
          body: child,

          // Show SupportHub globally on all screens except during Splash/Initial loading
          // You can add logic here if you have a specific route name for Splash
          floatingActionButton: SupportHub(primaryAccent: primaryAccent),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },

      // Initial screen of the app
      home: DashboardScreen(onThemeChanged: toggleTheme),
    );
  }
}
