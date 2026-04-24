import 'package:flutter/material.dart';
import 'app_colors.dart';

/// City Life Typography System
/// Display: Sora — geometric, modern, authoritative
/// Body: DM Sans — clean, readable, friendly
abstract class AppTypography {
  static const String displayFont = 'Sora';
  static const String bodyFont = 'DM Sans';

  // ── Display ────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // ── Headlines ──────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: displayFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ── Body ───────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ── Labels ─────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ── Special ────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: displayFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.2,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );
}
