import 'package:flutter/material.dart';

/// Visual middle ground between the light and dark Triply mockups:
/// misty sage background, cream cards, deep teal actions.
class AppTheme {
  static const Color primary = Color(0xFF0C4A52);
  static const Color primarySoft = Color(0xFF1B5C64);
  static const Color mistTop = Color(0xFF9FB8B3);
  static const Color mistBottom = Color(0xFFE4EEEC);
  static const Color cream = Color(0xFFF7FAF8);
  static const Color ink = Color(0xFF14343A);
  static const Color muted = Color(0xFF4F6B68);
  static const Color outline = Color(0xFFB4C7C3);
  static const Color introTeal = Color(0xFF0E5860);
  static const Color introCanvas = Color(0xFFF6F1E8);
  static const Color brandInk = Color(0xFF12343C);
  static const Color brandSoft = Color(0xFF3E5C5A);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: cream,
      surface: cream,
      onSurface: ink,
      secondary: const Color(0xFF5B8A82),
      onSecondary: cream,
      secondaryContainer: const Color(0xFFD5E4E0),
      onSecondaryContainer: ink,
      tertiaryContainer: const Color(0xFFE7DCC8),
      onTertiaryContainer: ink,
      error: const Color(0xFFB42318),
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'PlusJakartaSans',
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: ink,
            displayColor: ink,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: cream.withValues(alpha: 0.92),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cream,
        selectedColor: primary,
        disabledColor: cream,
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: cream, fontWeight: FontWeight.w600),
        side: const BorderSide(color: outline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        labelStyle: const TextStyle(color: muted),
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: cream,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
