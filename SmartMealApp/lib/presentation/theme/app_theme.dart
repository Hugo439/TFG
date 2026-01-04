import 'package:flutter/material.dart';
import 'colors.dart';

/// Configuración de temas Material 3 para SmartMeal.
///
/// Responsabilidades:
/// - Definir lightTheme y darkTheme completos
/// - Paleta de colores personalizada (AppColors)
/// - Estilos de texto consistentes
/// - Componentes Material 3
///
/// Material 3:
/// - useMaterial3: true
/// - ColorScheme completo con roles semánticos
/// - Nuevas propiedades: surfaceContainerHighest, surfaceBright, etc.
/// - Elevation system actualizado
///
/// lightTheme:
/// - Brightness.light
/// - primary: AppColors.primary (#5E56E7)
/// - secondary: AppColors.secondary (#FF9F66)
/// - tertiary: AppColors.tertiary (beige/cream)
/// - surface: AppColors.primaryBackground (blanco/gris claro)
/// - Todos los roles de color definidos
///
/// darkTheme:
/// - Brightness.dark
/// - primary: AppColors.primary (mismo base)
/// - surface: AppColors.darkPrimaryBackground (#1A1A2E)
/// - onSurface: AppColors.darkPrimaryText (blanco/gris claro)
/// - Colores adaptados para contraste en oscuro
///
/// TextTheme:
/// - displayLarge: 32px, bold
/// - displayMedium: 28px, bold
/// - displaySmall: 24px, bold
/// - headlineLarge: 22px, w600
/// - headlineMedium: 20px, w600
/// - headlineSmall: 18px, w600
/// - titleLarge: 18px, w600
/// - titleMedium: 16px, w600
/// - titleSmall: 14px, w600
/// - bodyLarge: 16px, regular
/// - bodyMedium: 14px, regular
/// - bodySmall: 12px, regular
/// - labelLarge: 14px, w600
/// - labelMedium: 12px, w600
/// - labelSmall: 11px, w600
///
/// AppBarTheme:
/// - backgroundColor: tertiary
/// - elevation: 0
/// - centerTitle: true
/// - iconTheme y titleTextStyle definidos
///
/// CardTheme:
/// - shape: RoundedRectangleBorder(16px)
/// - elevation: 2
/// - Colores: surface con outline
///
/// ButtonTheme:
/// - ElevatedButton: primary background
/// - TextButton: primary foreground
/// - OutlinedButton: border primary
/// - Shapes con borderRadius 12px
///
/// InputDecorationTheme:
/// - filled: true
/// - borderRadius: 12px
/// - focusedBorder: primary
/// - enabledBorder: outline
///
/// FloatingActionButtonTheme:
/// - backgroundColor: primary
/// - foregroundColor: onPrimary
/// - shape: circular
///
/// Uso:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
///
/// Acceso a colores:
/// ```dart
/// final colorScheme = Theme.of(context).colorScheme;
/// Container(color: colorScheme.primary)
/// ```
///
/// Texto con tema:
/// ```dart
/// final textTheme = Theme.of(context).textTheme;
/// Text('Título', style: textTheme.headlineMedium)
/// ```
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
      onSecondary: AppColors.darkOnSurface,
      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkOnSurface,
      error: AppColors.darkError,
      onError: AppColors.darkWhite,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      surfaceContainerLow: AppColors.darkSurfaceContainer,
      surfaceBright: AppColors.darkSurfaceContainerHigh,
      surfaceDim: AppColors.darkPrimaryBackground,
      primaryContainer: AppColors.darkSurfaceContainer,
      onPrimaryContainer: AppColors.darkOnSurface,
      secondaryContainer: AppColors.darkSurfaceContainerHigh,
      onSecondaryContainer: AppColors.darkOnSurfaceVariant,
      tertiaryContainer: AppColors.darkAccent4,
      onTertiaryContainer: AppColors.darkOnSurface,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
    ),
    scaffoldBackgroundColor: AppColors.darkPrimaryBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkOnSurface),
      titleTextStyle: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: AppColors.darkOnSurface, fontSize: 16),
      bodyMedium: TextStyle(
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 14,
      ),
      bodySmall: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 12),
      labelLarge: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 10,
      ),
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
      color: AppColors.darkSurfaceContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkOutline),
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
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkOnSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
