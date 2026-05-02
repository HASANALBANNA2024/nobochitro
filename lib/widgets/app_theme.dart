// lib/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // custom color image
  static const Color primaryTeal = Color(0xFF1D5A5D); // Teal color from buttons/text
  static const Color accentGold = Color(0xFFD4AF37); // Gold/Icon color
  static const Color backgroundLight = Color(0xFFF9F9F9); // Very light grey background
  static const Color surfaceWhite = Colors.white; // Card/Nav surface
  static const Color textDark = Color(0xFF111111); // Main text
  static const Color textLightGrey = Color(0xFF8E8E8E); // Subtitle text

  static const Color backgroundDark = Color(0xFF121212); // Deep dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Darker grey for cards
  static const Color textWhite = Colors.white; // Dark mode main text

  // 1. LIGHT THEME configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: accentGold,
        surface: surfaceWhite,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSurface: textDark,
        onBackground: textDark,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: TextStyle(fontSize: 14, color: textDark),
        bodyMedium: TextStyle(fontSize: 12, color: textLightGrey),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryTeal,
        unselectedItemColor: textLightGrey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // 2. DARK THEME Dark Theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textWhite),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: accentGold,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: Colors.white,
        onSurface: textWhite,
        onBackground: textWhite,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textWhite),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textWhite),
        bodyLarge: TextStyle(fontSize: 14, color: textWhite),
        bodyMedium: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}