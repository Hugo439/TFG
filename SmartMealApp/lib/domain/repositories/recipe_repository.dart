import 'package:smartmeal/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getAllRecipes();
  Future<List<Recipe>> getRecipesByMealType(MealType mealType);
  Future<List<Recipe>> getRecipesByTags(List<String> tags);
  Future<Recipe> getRecipeById(String id);
  Future<void> addRecipe(Recipe recipe);
  Future<void> updateRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);
  Future<List<Recipe>> searchRecipes(String query);
}