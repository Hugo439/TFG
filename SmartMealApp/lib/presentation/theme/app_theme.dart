import 'package:flutter/material.dart';
import 'colors.dart';

/// Tema principal de la app SmartMeal (modo claro y oscuro).
/// Adaptado completamente a Material 3 con la paleta personalizada.
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.primaryText,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.primaryText,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.primaryBackground,
      onSurface: AppColors.primaryText,
      surfaceContainerHighest: AppColors.tertiary,
      surfaceContainerLow: AppColors.accent3,
      surfaceBright: AppColors.alternate,
      surfaceDim: AppColors.secondaryBackground,
      primaryContainer: AppColors.secondary,
      onPrimaryContainer: AppColors.primaryText,
      secondaryContainer: AppColors.tertiary,
      onSecondaryContainer: AppColors.secondaryText,
      tertiaryContainer: AppColors.accent4,
      onTertiaryContainer: AppColors.primaryText,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      outline: AppColors.secondaryText,
      outlineVariant: AppColors.accent4,
    ),
    scaffoldBackgroundColor: AppColors.primaryBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.tertiary,
      foregroundColor: AppColors.primaryText,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primaryText),
      titleTextStyle: TextStyle(
        color: AppColors.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.primaryText,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.primaryText,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.primaryText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: AppColors.primaryText,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.primaryText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.primaryText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.secondaryText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: AppColors.primaryText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.secondaryText, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.secondaryText, fontSize: 12),
      labelLarge: TextStyle(
        color: AppColors.primaryText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: AppColors.secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(color: AppColors.secondaryText, fontSize: 10),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.tertiary,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondaryText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkWhite,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkPrimaryText,
      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkPrimaryText,
      error: AppColors.darkError,
      onError: AppColors.darkWhite,
      surface: AppColors.darkPrimaryBackground,
      onSurface: AppColors.darkPrimaryText,
      surfaceContainerHighest: AppColors.darkSecondaryBackground,
      surfaceContainerLow: AppColors.darkAccent3,
      surfaceBright: AppColors.darkSecondaryBackground,
      surfaceDim: AppColors.darkPrimaryBackground,
      primaryContainer: AppColors.darkAccent3,
      onPrimaryContainer: AppColors.darkPrimaryText,
      secondaryContainer: AppColors.darkTertiary,
      onSecondaryContainer: AppColors.darkSecondaryText,
      tertiaryContainer: AppColors.darkAccent4,
      onTertiaryContainer: AppColors.darkPrimaryText,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      outline: AppColors.darkSecondaryText,
      outlineVariant: AppColors.darkAccent4,
    ),
    scaffoldBackgroundColor: AppColors.darkPrimaryBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSecondaryBackground,
      foregroundColor: AppColors.darkWhite,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkWhite),
      titleTextStyle: TextStyle(
        color: AppColors.darkWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.darkSecondaryText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: AppColors.darkPrimaryText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.darkSecondaryText, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.darkSecondaryText, fontSize: 12),
      labelLarge: TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: AppColors.darkSecondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(color: AppColors.darkSecondaryText, fontSize: 10),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkWhite,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkWhite,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSecondaryBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSecondaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkError),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSecondaryBackground,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkSecondaryText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
