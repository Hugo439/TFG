import 'package:flutter/material.dart';
import 'colors.dart';

/// Helpers para obtener colores según el tema actual
class ThemeHelpers {
  /// Obtener color de texto primario según tema
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Obtener color de texto secundario según tema
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
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
        return isDark ? AppColors.darkCategoryErrores : AppColors.categoryErrores;
      case 'Sugerencias':
        return isDark ? AppColors.darkCategorySugerencias : AppColors.categorySugerencias;
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