import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF5B9BD5);
  static const Color softGreen = Color(0xFF70C1B3);
  static const Color warmOrange = Color(0xFFFFB347);
  static const Color softPink = Color(0xFFFF6B6B);
  static const Color lightYellow = Color(0xFFFFF3B0);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color darkGray = Color(0xFF2D3436);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: offWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: softGreen,
        error: softPink,
        surface: offWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
