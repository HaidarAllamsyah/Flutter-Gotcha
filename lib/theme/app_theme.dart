import 'package:flutter/material.dart';

class AppTheme {
  // ─── MATCHA COLOR PALETTE ───────────────────────────
  static const Color primary = Color(0xFF6B7D1F); // Hijau tua matcha
  static const Color secondary = Color(0xFFB7D64A); // Hijau segar
  static const Color tertiary = Color(0xFFA9B388); // Hijau muda lembut
  static const Color accent = Color(0xFFF3F1E7); // Hijau sangat muda
  static const Color cream = Color(0xFFF8F4E3); // Krem hangat
  static const Color brown = Color(0xFF6B4F3A); // Coklat matcha
  static const Color error = Color(0xFFE63946);
  static const Color warning = Color(0xFFF4A261);
  static const Color success = Color(0xFFB7D64A);
  static const Color bgLight = Color(0xFFF8F9F4); // Background utama
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1B1B1B);
  static const Color textMedium = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE8EDE9);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: bgLight,
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          background: bgLight,
          surface: bgCard,
          error: error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: textLight),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: textLight,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
