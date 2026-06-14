import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.manrope(
      fontSize: 72,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
      letterSpacing: -2.0,
    ),
    displayMedium: GoogleFonts.manrope(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
      letterSpacing: -1.0,
    ),
    headlineLarge: GoogleFonts.manrope(
      fontSize: 36,
      fontWeight: FontWeight.w300,
      color: AppColors.onSurface,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
    ),
    headlineSmall: GoogleFonts.manrope(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    titleLarge: GoogleFonts.manrope(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurfaceVariant,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
      height: 1.4,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
      letterSpacing: 1.5,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
      letterSpacing: 1.2,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: AppColors.outline,
      letterSpacing: 1.0,
    ),
  );
}
