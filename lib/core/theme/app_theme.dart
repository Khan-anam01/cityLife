import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────────────
  // LIGHT THEME
  // ──────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          secondary: AppColors.accent,
          onSecondary: AppColors.white,
          error: AppColors.error,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,

        // AppBar
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          centerTitle: false,
          titleTextStyle: AppTypography.headlineMedium,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          iconTheme: IconThemeData(
            color: AppColors.textPrimary,
            size: AppSpacing.iconMd,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingH,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            textStyle: AppTypography.buttonText,
          ),
        ),

        // OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            elevation: 0,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingH,
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            textStyle: AppTypography.buttonText,
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: AppTypography.labelLarge.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.inputPaddingH,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          labelStyle: AppTypography.labelMedium,
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTypography.navLabel,
          unselectedLabelStyle: AppTypography.navLabel,
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.background,
          selectedColor: AppColors.primary.withOpacity(0.1),
          labelStyle: AppTypography.labelMedium,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // Text
        textTheme: const TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          displaySmall: AppTypography.displaySmall,
          headlineLarge: AppTypography.headlineLarge,
          headlineMedium: AppTypography.headlineMedium,
          headlineSmall: AppTypography.headlineSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
      );

  // ──────────────────────────────────────────────────────
  // DARK THEME
  // ──────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: AppColors.primary,
          secondary: AppColors.accentLight,
          onSecondary: AppColors.primary,
          error: AppColors.error,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkBackground,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.darkBackground,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),

        // Dark theme
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
            elevation: 0,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            textStyle: AppTypography.buttonText,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.inputPaddingH,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.darkTextSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTypography.navLabel,
          unselectedLabelStyle: AppTypography.navLabel,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 1,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          displayMedium: AppTypography.displayMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          displaySmall: AppTypography.displaySmall.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          headlineLarge: AppTypography.headlineLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          headlineMedium: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          headlineSmall: AppTypography.headlineSmall.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          bodyLarge: AppTypography.bodyLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          bodyMedium: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          bodySmall: AppTypography.bodySmall.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          labelLarge: AppTypography.labelLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          labelMedium: AppTypography.labelMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          labelSmall: AppTypography.labelSmall.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
      );
}
