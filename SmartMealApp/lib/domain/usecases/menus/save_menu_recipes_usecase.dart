import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

/// UseCase para guardar todas las recetas de un menú semanal.
///
/// Responsabilidad:
/// - Iterar sobre todas las recetas del menú (7 días × 4 comidas = 28 recetas)
/// - Validar cada receta antes de guardar
/// - Persistir recetas válidas en Firestore
///
/// Entrada:
/// - WeeklyMenu completo con todos los DayMenu y Recipe entities
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Validación de recetas:
/// - RecipeName válido (no vacío, longitud correcta)
/// - RecipeDescription válido
/// - Al menos 1 ingrediente
/// - Calorías > 0
///
/// Uso típico:
/// ```dart
/// // Después de generar menú con IA
/// final menu = await generateWeeklyMenuUseCase(...);
/// await saveMenuRecipesUseCase(menu); // Guarda las 28 recetas
/// ```
///
/// Nota: Recetas inválidas se omiten silenciosamente.
class SaveMenuRecipesUseCase {
  final RecipeRepository recipeRepository;

  SaveMenuRecipesUseCase(this.recipeRepository);

  Future<void> call(WeeklyMenu menu) async {
    for (final day in menu.days) {
      for (final receta in day.recipes) {
        if (_validateRecipe(receta)) {
          await recipeRepository.saveRecipe(receta);
        }
      }
    }
  }

  /// Valida que una receta tenga datos correctos.
  ///
  /// Criterios:
  /// - Name y Description pasan validación de Value Objects
  /// - Tiene al menos 1 ingrediente
  /// - Calorías > 0
  ///
  /// Returns: true si válida, false si inválida.
  bool _validateRecipe(Recipe recipe) {
    try {
      RecipeName(recipe.name.value);
      RecipeDescription(recipe.description.value);
      return recipe.ingredients.isNotEmpty && recipe.calories > 0;
    } catch (_) {
      return false;
    }
  }
}
