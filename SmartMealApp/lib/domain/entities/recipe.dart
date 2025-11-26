import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

enum MealType { breakfast, lunch, dinner, snack }

class Recipe {
  final String id;
  final RecipeName name;
  final RecipeDescription description;
  final List<String> ingredients;
  final int calories;
  final MealType mealType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.mealType,
    this.createdAt,
    this.updatedAt,
  });
}