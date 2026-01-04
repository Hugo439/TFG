import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/data/models/recipe_model.dart';
import 'package:smartmeal/core/utils/meal_type_utils.dart';

/// Mapper para convertir entre Recipe (dominio) y RecipeModel (datos).
///
/// Conversiones:
/// - **fromEntity**: Recipe → RecipeModel (para persistencia)
/// - **toEntity**: RecipeModel → Recipe (delegado al modelo)
///
/// Transformaciones:
/// - MealType enum ↔ String (usando meal_type_utils)
/// - Value Objects (RecipeName, RecipeDescription) ↔ primitivos
///
/// Nota: RecipeModel tiene método toEntity() propio, por eso toEntity
/// simplemente delega al modelo.
class RecipeMapper {
  /// Convierte Recipe (dominio) a RecipeModel (datos).
  ///
  /// Extrae valores de Value Objects y convierte enum MealType a string.
  ///
  /// [entity] - Receta del dominio.
  ///
  /// Returns: Modelo listo para Firestore.
  static RecipeModel fromEntity(Recipe entity) {
    return RecipeModel(
      id: entity.id,
      name: entity.name.value,
      description: entity.description.value,
      ingredients: entity.ingredients,
      calories: entity.calories,
      mealType: mealTypeToString(entity.mealType),
      steps: entity.steps,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte RecipeModel a Recipe.
  ///
  /// Delega al método toEntity() del modelo que maneja
  /// la creación de Value Objects y conversión de string a MealType.
  ///
  /// [model] - Modelo desde Firestore.
  ///
  /// Returns: Receta del dominio.
  static Recipe toEntity(RecipeModel model) {
    return model.toEntity();
  }
}
