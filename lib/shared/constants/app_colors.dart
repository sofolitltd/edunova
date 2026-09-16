import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4F46E5);
  static const primarySurface = Color(0xFFEEF2FF);

  // ── Accent ───────────────────────────────────────────
  static const accent = Color(0xFFF472B6);
  static const accentLight = Color(0xFFFBCFE8);

  // ── Neutrals (Light) ─────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // ── Neutrals (Dark) ──────────────────────────────────
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceElevated = Color(0xFF334155);
  static const darkBorder = Color(0xFF475569);
  static const darkBorderLight = Color(0xFF334155);

  // ── Text (Light) ─────────────────────────────────────
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Text (Dark) ──────────────────────────────────────
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextTertiary = Color(0xFF64748B);
  static const darkTextOnPrimary = Color(0xFFFFFFFF);

  // ── States ───────────────────────────────────────────
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const errorSurface = Color(0xFFFEF2F2);
  static const warning = Color(0xFFF59E0B);

  // ── Dark States ──────────────────────────────────────
  static const darkError = Color(0xFFF87171);
  static const darkErrorSurface = Color(0xFF450A0A);

  // ── Gradient ─────────────────────────────────────────
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFEC4899)],
  );

  static const gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEEF2FF), background],
  );

  static const darkGradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E293B), darkBackground],
  );

  // ── Theme-aware getters ──────────────────────────────
  static Color backgroundFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : background;

  static Color surfaceFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : surface;

  static Color surfaceElevatedFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurfaceElevated
          : surfaceElevated;

  static Color borderFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : border;

  static Color borderLightFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorderLight
          : borderLight;

  static Color textPrimaryFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextPrimary
          : textPrimary;

  static Color textSecondaryFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextSecondary
          : textSecondary;

  static Color textTertiaryFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextTertiary
          : textTertiary;

  static Color errorFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkError
          : error;

  static Color errorSurfaceFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkErrorSurface
          : errorSurface;

  static LinearGradient gradientBackgroundFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkGradientBackground
          : gradientBackground;
}