import 'package:flutter/material.dart';
import 'colors.dart';

/// Helpers para obtener colores adaptativos según tema actual.
///
/// Responsabilidades:
/// - Obtener colores que se adaptan a light/dark
/// - Helpers para texto, backgrounds, cards
/// - Colores de categorías de soporte
/// - Colores de estados
///
/// Ventajas:
/// - Centralización de lógica de tema
/// - Evita repetir Theme.of(context).brightness
/// - Facilita cambios de colores globales
///
/// Métodos principales:
/// - **textPrimary**: color de texto principal
/// - **textSecondary**: color de texto secundario (alpha 0.7)
/// - **backgroundPrimary**: fondo principal (surface)
/// - **backgroundSecondary**: fondo secundario (surfaceContainerHighest)
/// - **cardBackground**: fondo de cards (adapta a tema)
/// - **getCategoryColor**: color por categoría de soporte
/// - **getStatusColor**: color por estado (pending, resolved, closed)
///
/// getCategoryColor:
/// - Dudas: azul
/// - Errores: rojo
/// - Sugerencias: verde/amarillo
/// - Cuenta: morado
/// - Menús: naranja
/// - Otro: gris
/// - Default: secondaryText
///
/// getStatusColor:
/// - pending: naranja/warning
/// - resolved: verde/success
/// - closed: gris/secondaryText
/// - Default: secondaryText
///
/// Uso:
/// ```dart
/// Text(
///   'Título',
///   style: TextStyle(color: ThemeHelpers.textPrimary(context)),
/// )
///
/// Container(
///   color: ThemeHelpers.backgroundSecondary(context),
///   child: ...,
/// )
///
/// Icon(
///   Icons.help,
///   color: ThemeHelpers.getCategoryColor('Dudas', context),
/// )
/// ```
class ThemeHelpers {
  /// Obtener color de texto primario según tema
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Obtener color de texto secundario según tema
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
  }

  /// Obtener color de fondo primario según tema
  static Color backgroundPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Obtener color de fondo secundario según tema
  static Color backgroundSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  /// Obtener color de card/contenedor según tema
  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkSecondaryBackground
        : AppColors.white;
  }

  /// Helper para obtener color de categoría según tema
  static Color getCategoryColor(String? category, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (category) {
      case 'Dudas':
        return isDark ? AppColors.darkCategoryDudas : AppColors.categoryDudas;
      case 'Errores':
        return isDark
            ? AppColors.darkCategoryErrores
            : AppColors.categoryErrores;
      case 'Sugerencias':
        return isDark
            ? AppColors.darkCategorySugerencias
            : AppColors.categorySugerencias;
      case 'Cuenta':
        return isDark ? AppColors.darkCategoryCuenta : AppColors.categoryCuenta;
      case 'Menús':
        return isDark ? AppColors.darkCategoryMenus : AppColors.categoryMenus;
      case 'Otro':
        return isDark ? AppColors.darkCategoryOtro : AppColors.categoryOtro;
      default:
        return isDark ? AppColors.darkSecondaryText : AppColors.secondaryText;
    }
  }

  /// Helper para obtener color de estado según tema
  static Color getStatusColor(String? status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case 'respondido':
        return isDark ? AppColors.darkSuccess : AppColors.success;
      case 'en proceso':
        return isDark ? AppColors.darkWarning : AppColors.warning;
      case 'pendiente':
        return isDark ? AppColors.darkInfo : AppColors.info;
      default:
        return isDark ? AppColors.darkSecondaryText : AppColors.secondaryText;
    }
  }
}
