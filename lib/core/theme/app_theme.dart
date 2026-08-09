import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark theme colors (Compact Professional Dark)
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF293548);
  static const Color border = Color(0xFF334155);

  // Accent colors (solid/flat)
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color accentMint = Color(0xFF34D399);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentCoral = Color(0xFFFB7185);

  // Legacy aliases (keep for backward compat during migration)
  static const Color accent = accentCyan;
  static const Color accentSoft = Color(0x1E38BDF8);
  static const Color mint = accentMint;
  static const Color mintSoft = Color(0x1E34D399);
  static const Color amber = accentAmber;
  static const Color amberSoft = Color(0x1EFBBF24);
  static const Color coral = accentCoral;
  static const Color coralSoft = Color(0x1EFB7185);

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color divider = Color(0xFF2A3545);
  static const Color inputFill = Color(0xFF1A2332);
  static const Color inputBorder = Color(0xFF3A4A5C);

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF5F3EF);
  static const Color lightAccent = Color(0xFF5A7A99);
  static const Color lightAccentSoft = Color(0x1E5A7A99);
  static const Color lightMint = Color(0xFF5E8A6A);
  static const Color lightMintSoft = Color(0x1E5E8A6A);
  static const Color lightAmber = Color(0xFFA08848);
  static const Color lightAmberSoft = Color(0x1EA08848);
  static const Color lightCoral = Color(0xFF945555);
  static const Color lightCoralSoft = Color(0x1E945555);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFE5E1DA);
  static const Color lightInputFill = Color(0xFFF5F3EF);
  static const Color lightInputBorder = Color(0xFFD1C9BC);

  // Spacing constants (compact layout)
  static const double spacingXs = 4.0;
  static const double spacingSm = 6.0;
  static const double spacingMd = 8.0;
  static const double spacingBase = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2xl = 48.0;
  static const double spacing3xl = 64.0;

  // Border radius constants (compact layout)
  static const double radiusCard = 8.0;
  static const double radiusButton = 6.0;
  static const double radiusInput = 6.0;
  static const double radiusChip = 14.0;
  static const double radiusFab = 20.0;
  static const double radiusDialog = 16.0;

  // Text styles using google_fonts
  static TextStyle display(BuildContext context) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.01,
        color: Theme.of(context).brightness == Brightness.dark
            ? textPrimary
            : lightTextPrimary,
      );

  static TextStyle h1(BuildContext context) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.01,
        color: Theme.of(context).brightness == Brightness.dark
            ? textPrimary
            : lightTextPrimary,
      );

  static TextStyle h2(BuildContext context) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark
            ? textPrimary
            : lightTextPrimary,
      );

  static TextStyle h3(BuildContext context) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark
            ? textPrimary
            : lightTextPrimary,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark
            ? textPrimary
            : lightTextPrimary,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
        color: Theme.of(context).brightness == Brightness.dark
            ? textSecondary
            : lightTextSecondary,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: 0.02,
        color: Theme.of(context).brightness == Brightness.dark
            ? textTertiary
            : lightTextTertiary,
      );

  static TextStyle small(BuildContext context) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.04,
        color: Theme.of(context).brightness == Brightness.dark
            ? textTertiary
            : lightTextTertiary,
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: mint,
          surface: surface,
          error: coral,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onError: Colors.white,
        ),
        cardColor: surface,
        dividerColor: divider,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardTheme(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingBase,
              vertical: spacingMd,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: const BorderSide(color: accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingBase,
              vertical: spacingMd,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          filled: true,
          fillColor: inputFill,
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textSecondary),
        ),
        dividerTheme: const DividerThemeData(
          color: divider,
          thickness: 1,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: surface,
          contentTextStyle: const TextStyle(color: textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            bodyLarge: TextStyle(color: textPrimary),
            bodyMedium: TextStyle(color: textPrimary),
            bodySmall: TextStyle(color: textSecondary),
            labelLarge: TextStyle(color: textPrimary),
            labelMedium: TextStyle(color: textSecondary),
            labelSmall: TextStyle(color: textTertiary),
          ),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: const ColorScheme.light(
          primary: lightAccent,
          secondary: lightMint,
          surface: lightSurface,
          error: lightCoral,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: lightTextPrimary,
          onError: Colors.white,
        ),
        cardColor: lightSurface,
        dividerColor: lightDivider,
        appBarTheme: const AppBarTheme(
          backgroundColor: lightSurface,
          foregroundColor: lightTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardTheme(
          color: lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingBase,
              vertical: spacingMd,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: lightAccent,
            side: const BorderSide(color: lightAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingBase,
              vertical: spacingMd,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: lightInputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: lightInputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: lightAccent, width: 2),
          ),
          filled: true,
          fillColor: lightInputFill,
          labelStyle: const TextStyle(color: lightTextSecondary),
          hintStyle: const TextStyle(color: lightTextSecondary),
        ),
        dividerTheme: const DividerThemeData(
          color: lightDivider,
          thickness: 1,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: lightAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: lightSurface,
          contentTextStyle: const TextStyle(color: lightTextPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            bodyLarge: TextStyle(color: lightTextPrimary),
            bodyMedium: TextStyle(color: lightTextPrimary),
            bodySmall: TextStyle(color: lightTextSecondary),
            labelLarge: TextStyle(color: lightTextPrimary),
            labelMedium: TextStyle(color: lightTextSecondary),
            labelSmall: TextStyle(color: lightTextTertiary),
          ),
        ),
      );
}
