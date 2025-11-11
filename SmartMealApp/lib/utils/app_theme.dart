import 'package:flutter/material.dart';
import 'colors.dart';

/// Tema principal de la app SmartMeal (modo claro y oscuro).
/// Adaptado completamente a Material 3.
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryBackgroundLight,
      onSecondary: AppColors.primaryTextLight,
      tertiary: AppColors.tertiaryLight,
      onTertiary: AppColors.primaryTextLight,
      error: AppColors.errorLight,
      onError: Colors.white,
      surface: AppColors.primaryBackgroundLight,
      onSurface: AppColors.primaryTextLight,
      surfaceContainerHighest: AppColors.secondaryBackgroundLight,
      surfaceContainerLow: AppColors.accent3Light,
      surfaceBright: AppColors.primaryBackgroundLight,
      surfaceDim: AppColors.secondaryBackgroundLight,
    ),
    scaffoldBackgroundColor: AppColors.primaryBackgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.primaryTextLight,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.secondaryTextLight,
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        color: AppColors.primaryTextLight,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.secondaryBackgroundLight,
      elevation: 1,
      margin: EdgeInsets.all(8), // quitar margin si da errores
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryBackgroundDark,
      onSecondary: AppColors.primaryTextDark,
      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.primaryTextDark,
      error: AppColors.errorDark,
      onError: Colors.white,
      surface: AppColors.primaryBackgroundDark,
      onSurface: AppColors.primaryTextDark,
      surfaceContainerHighest: AppColors.secondaryBackgroundDark,
      surfaceContainerLow: AppColors.accent3Dark,
      surfaceBright: AppColors.secondaryBackgroundDark,
      surfaceDim: AppColors.primaryBackgroundDark,
    ),
    scaffoldBackgroundColor: AppColors.primaryBackgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.primaryTextDark,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.secondaryTextDark,
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        color: AppColors.primaryTextDark,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.secondaryBackgroundDark,
      elevation: 1,
      margin: EdgeInsets.all(8), // quitar margin si da errores
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}

