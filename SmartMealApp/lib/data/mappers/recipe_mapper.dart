import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/data/models/recipe_model.dart';
import 'package:smartmeal/core/utils/meal_type_utils.dart';

class RecipeMapper {
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

  static Recipe toEntity(RecipeModel model) {
    return model.toEntity();
  }
}