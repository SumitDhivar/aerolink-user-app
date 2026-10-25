import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// AppTheme builds the Material Design 3 ThemeData for AeroLink.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.brandNavy,
        onPrimary: AppColors.surfaceWhite,
        primaryContainer: AppColors.brandNavyLight,
        onPrimaryContainer: AppColors.surfaceWhite,
        secondary: AppColors.brandTeal,
        onSecondary: AppColors.surfaceWhite,
        secondaryContainer: AppColors.infoContainer,
        onSecondaryContainer: AppColors.brandTealDark,
        tertiary: AppColors.brandAmber,
        onTertiary: AppColors.neutral900,
        error: AppColors.error,
        onError: AppColors.surfaceWhite,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.error,
        surface: AppColors.surfaceWhite,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral100,
        onSurfaceVariant: AppColors.neutral700,
        outline: AppColors.neutral300,
        outlineVariant: AppColors.neutral200,
      ),
      scaffoldBackgroundColor: AppColors.softNeutral,
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brandNavy,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.surfaceWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandNavy,
          foregroundColor: AppColors.surfaceWhite,
          minimumSize: const Size(double.infinity, AppSpacing.space48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space12,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.border8),
          elevation: 0,
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.surfaceWhite),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandNavy,
          minimumSize: const Size(double.infinity, AppSpacing.space48),
          side: const BorderSide(color: AppColors.brandNavy, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.border8),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space12,
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.brandNavy),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.border8,
          borderSide: const BorderSide(color: AppColors.neutral300, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.border8,
          borderSide: const BorderSide(color: AppColors.neutral300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.border8,
          borderSide: const BorderSide(color: AppColors.brandNavy, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.border8,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.border8,
          borderSide: const BorderSide(color: AppColors.error, width: 2.0),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral700),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500),
        errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.border12,
          side: const BorderSide(color: AppColors.neutral200, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 3.0,
        indicatorColor: AppColors.brandTeal.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brandTeal);
          }
          return const IconThemeData(color: AppColors.neutral600);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.brandTeal,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.neutral600,
          );
        }),
      ),
    );
  }
}
