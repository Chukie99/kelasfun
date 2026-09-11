import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === MAROON FLAT — Putih + Maroon #7A1C1C (no gold) ===
  // Primary maroon deep, bg putih bersih, tint #FFF0F0
  static const Color primary = Color(0xFF7A1C1C);
  static const Color primarySoft = Color(0x1E7A1C1C);
  static const Color primaryLight = Color(0xFF9B1B30);
  static const Color tintBg = Color(0xFFFFF0F0);
  static const Color tintLine = Color(0xFFE8D0D0);

  // Dark theme — maroon tinted dark
  static const Color background = Color(0xFF1A0F0F);
  static const Color surface = Color(0xFF2A1414);
  static const Color surfaceLight = Color(0xFF3A1E1E);
  static const Color border = Color(0xFF4A2A2A);

  static const Color accentCyan = primary;
  static const Color accentMint = Color(0xFF2E7D6B);
  static const Color accentAmber = Color(0xFF9B1B30);
  static const Color accentCoral = Color(0xFFB03040);

  static const Color accent = primary;
  static const Color accentSoft = primarySoft;
  static const Color mint = accentMint;
  static const Color mintSoft = Color(0x1E2E7D6B);
  static const Color amber = accentAmber;
  static const Color amberSoft = Color(0x1E9B1B30);
  static const Color coral = accentCoral;
  static const Color coralSoft = Color(0x1EB03040);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFE8CFCF);
  static const Color textTertiary = Color(0xFFC9A0A0);
  static const Color divider = Color(0xFF3A1E1E);
  static const Color inputFill = Color(0xFF2A1414);
  static const Color inputBorder = Color(0xFF4A2A2A);

  // Light theme — Putih + Maroon
  static const Color lightBackground = Color(0xFFFFFCFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFFFF5F5);
  static const Color lightBorder = Color(0xFFE8D0D0);

  static const Color lightAccentCyan = primary;
  static const Color lightAccentMint = Color(0xFF2E7D6B);
  static const Color lightAccentAmber = Color(0xFF9B1B30);
  static const Color lightAccentCoral = Color(0xFFB03040);

  static const Color lightAccent = primary;
  static const Color lightMint = lightAccentMint;
  static const Color lightAmber = lightAccentAmber;
  static const Color lightCoral = lightAccentCoral;

  static const Color lightAccentSoft = primarySoft;
  static const Color lightMintSoft = Color(0x1E2E7D6B);
  static const Color lightAmberSoft = Color(0x1E9B1B30);
  static const Color lightCoralSoft = Color(0x1EB03040);

  static const Color lightTextPrimary = Color(0xFF2B1A1A);
  static const Color lightTextSecondary = Color(0xFF8A6B6B);
  static const Color lightTextTertiary = Color(0xFFB89A9A);
  static const Color lightDivider = Color(0xFFF3E6E6);
  static const Color lightInputFill = Color(0xFFFFF5F5);
  static const Color lightInputBorder = Color(0xFFE8D0D0);

  static const double spacingXs = 4.0;
  static const double spacingSm = 6.0;
  static const double spacingMd = 8.0;
  static const double spacingBase = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2xl = 48.0;
  static const double spacing3xl = 64.0;

  static const double radiusCard = 8.0;
  static const double radiusButton = 6.0;
  static const double radiusInput = 6.0;
  static const double radiusChip = 14.0;
  static const double radiusFab = 20.0;
  static const double radiusDialog = 16.0;

  static TextStyle display(BuildContext context) => GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.01,
        color: Theme.of(context).brightness == Brightness.dark ? textPrimary : lightTextPrimary,
      );
  static TextStyle h1(BuildContext context) => GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: -0.01,
        color: Theme.of(context).brightness == Brightness.dark ? textPrimary : lightTextPrimary,
      );
  static TextStyle h2(BuildContext context) => GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark ? textPrimary : lightTextPrimary,
      );
  static TextStyle h3(BuildContext context) => GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w500, height: 1.35, letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark ? textPrimary : lightTextPrimary,
      );
  static TextStyle body(BuildContext context) => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark ? textPrimary : lightTextPrimary,
      );
  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark ? textSecondary : lightTextSecondary,
      );
  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, height: 1.3, letterSpacing: 0.02,
        color: Theme.of(context).brightness == Brightness.dark ? textTertiary : lightTextTertiary,
      );
  static TextStyle small(BuildContext context) => GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500, height: 1.3, letterSpacing: 0.04,
        color: Theme.of(context).brightness == Brightness.dark ? textTertiary : lightTextTertiary,
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(primary: accent, secondary: mint, surface: surface, error: coral, onPrimary: Colors.white, onSecondary: Colors.white, onSurface: textPrimary, onError: Colors.white),
        cardColor: surface, dividerColor: divider,
        appBarTheme: const AppBarTheme(backgroundColor: surface, foregroundColor: textPrimary, elevation: 0, surfaceTintColor: Colors.transparent),
        cardTheme: CardThemeData(color: surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)), padding: EdgeInsets.symmetric(horizontal: spacingBase, vertical: spacingMd))),
        outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: accent, side: BorderSide(color: accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)), padding: EdgeInsets.symmetric(horizontal: spacingBase, vertical: spacingMd))),
        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput), borderSide: BorderSide(color: inputBorder)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput), borderSide: BorderSide(color: inputBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput), borderSide: BorderSide(color: accent, width: 2)), filled: true, fillColor: inputFill, labelStyle: TextStyle(color: textSecondary), hintStyle: TextStyle(color: textSecondary)),
        dividerTheme: const DividerThemeData(color: divider, thickness: 1),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: accent, foregroundColor: Colors.white, elevation: 0),
        snackBarTheme: SnackBarThemeData(backgroundColor: surface, contentTextStyle: TextStyle(color: textPrimary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard)), behavior: SnackBarBehavior.floating),
        textTheme: GoogleFonts.interTextTheme(const TextTheme(bodyLarge: TextStyle(color: textPrimary), bodyMedium: TextStyle(color: textPrimary), bodySmall: TextStyle(color: textSecondary), labelLarge: TextStyle(color: textPrimary), labelMedium: TextStyle(color: textSecondary), labelSmall: TextStyle(color: textTertiary))),
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: const ColorScheme.light(primary: lightAccent, secondary: lightMint, surface: lightSurface, error: lightCoral, onPrimary: Colors.white, onSecondary: Colors.white, onSurface: lightTextPrimary, onError: Colors.white),
        cardColor: lightSurface, dividerColor: lightDivider,
        appBarTheme: const AppBarTheme(backgroundColor: lightSurface, foregroundColor: lightTextPrimary, elevation: 0, surfaceTintColor: Colors.transparent),
        cardTheme: CardThemeData(color: lightSurface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: lightAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)), padding: EdgeInsets.symmetric(horizontal: spacingBase, vertical: spacingMd))),
        outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: lightAccent, side: BorderSide(color: lightAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)), padding: EdgeInsets.symmetric(horizontal: spacingBase, vertical: spacingMd))),
        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput), borderSide: BorderSide(color: lightInputBorder)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput), borderSide: BorderSide(color: lightInputBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput), borderSide: BorderSide(color: lightAccent, width: 2)), filled: true, fillColor: lightInputFill, labelStyle: TextStyle(color: lightTextSecondary), hintStyle: TextStyle(color: lightTextSecondary)),
        dividerTheme: const DividerThemeData(color: lightDivider, thickness: 1),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: lightAccent, foregroundColor: Colors.white, elevation: 0),
        snackBarTheme: SnackBarThemeData(backgroundColor: lightSurface, contentTextStyle: TextStyle(color: lightTextPrimary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard)), behavior: SnackBarBehavior.floating),
        textTheme: GoogleFonts.interTextTheme(const TextTheme(bodyLarge: TextStyle(color: lightTextPrimary), bodyMedium: TextStyle(color: lightTextPrimary), bodySmall: TextStyle(color: lightTextSecondary), labelLarge: TextStyle(color: lightTextPrimary), labelMedium: TextStyle(color: lightTextSecondary), labelSmall: TextStyle(color: lightTextTertiary))),
      );
}
