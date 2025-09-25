import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentPink,
        tertiary: accentTeal,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLight,
        onBackground: textLight,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textLight,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textLight,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}