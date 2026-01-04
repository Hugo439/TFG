import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/recipe.dart';

/// Extensión para obtener icono de tipo de comida.
///
/// Responsabilidades:
/// - Mapear MealType a IconData
/// - Iconos temáticos Material
///
/// Mapeo:
/// - breakfast → free_breakfast (taza de café)
/// - lunch → lunch_dining (plato con cubiertos)
/// - dinner → dinner_dining (plato con tenedor/cuchillo)
/// - snack → fastfood (hamburguesa/snack)
///
/// Uso:
/// - RecipeDetailContent: icono en header
/// - RecipeListTile: identificación visual
/// - WeeklyMenuCalendar: iconos de comidas
///
/// Acceso:
/// ```dart
/// final icon = recipe.mealType.icon;
/// Icon(recipe.mealType.icon)
/// ```
extension MealTypeIcon on MealType {
  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.fastfood;
    }
  }
}
