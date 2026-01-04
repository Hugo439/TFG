import 'package:smartmeal/domain/entities/recipe.dart';

/// Extensión para obtener nombre localizado de tipo de comida.
///
/// Responsabilidades:
/// - Mapear MealType a texto en español
/// - Display names para UI
///
/// Mapeo:
/// - breakfast → "Desayuno"
/// - lunch → "Comida"
/// - dinner → "Cena"
/// - snack → "Snack"
///
/// Nota:
/// - Hardcoded en español (no usa l10n)
/// - Para multi-idioma, debería usar l10n
///
/// Uso:
/// - RecipeDetailContent: título de sección
/// - RecipeCard: etiqueta de tipo
/// - Cualquier UI que muestre meal type
///
/// Acceso:
/// ```dart
/// final name = recipe.mealType.displayName;
/// Text(recipe.mealType.displayName) // "Desayuno"
/// ```
extension MealTypeText on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Comida';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Snack';
    }
  }
}
