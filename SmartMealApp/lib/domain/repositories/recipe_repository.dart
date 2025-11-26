import 'package:smartmeal/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<Recipe?> getRecipeById(String id, String userId);
  Future<void> saveRecipe(Recipe recipe);
  Future<List<Recipe>> getAllRecipes(String userId);
  Future<List<Recipe>> getRecipesByMealType(MealType mealType, String userId);
}