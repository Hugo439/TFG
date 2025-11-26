import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

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