import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.anekBangla().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          onPrimary: Colors.white,
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF0F172A),
          error: Color(0xFFEF4444),
          outline: Color(0xFFE2E8F0),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.anekBangla().fontFamily,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF818CF8),
          onPrimary: Colors.white,
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF1F5F9),
          error: Color(0xFFF87171),
          outline: Color(0xFF334155),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
      );

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(64, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final _inputDecorationTheme = InputDecorationTheme(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}
