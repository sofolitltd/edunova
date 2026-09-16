import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _font(
    BuildContext context, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    double height = 1.5,
    Color? color,
  }) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    if (isBn) {
      return GoogleFonts.googleSans(
  
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }

    return GoogleFonts.googleSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle h1(BuildContext context) => _font(
        context,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.textPrimaryFor(context),
      );

  static TextStyle h2(BuildContext context) => _font(
        context,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
        color: AppColors.textPrimaryFor(context),
      );

  static TextStyle h3(BuildContext context) => _font(
        context,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: AppColors.textPrimaryFor(context),
      );

  static TextStyle bodyLarge(BuildContext context) => _font(
        context,
        fontSize: 16,
        color: AppColors.textPrimaryFor(context),
      );

  static TextStyle bodyMedium(BuildContext context) => _font(
        context,
        fontSize: 14,
        color: AppColors.textSecondaryFor(context),
      );

  static TextStyle bodySmall(BuildContext context) => _font(
        context,
        fontSize: 12,
        height: 1.4,
        color: AppColors.textTertiaryFor(context),
      );

  static TextStyle label(BuildContext context) => _font(
        context,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
        color: AppColors.textSecondaryFor(context),
      );

  static TextStyle buttonLarge(BuildContext context) => _font(
        context,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
        color: AppColors.textOnPrimary,
      );

  static TextStyle buttonMedium(BuildContext context) => _font(
        context,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.2,
        color: AppColors.textOnPrimary,
      );
}
