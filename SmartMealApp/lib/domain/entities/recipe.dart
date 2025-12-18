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
  final List<String> steps;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.mealType,
    this.steps = const [],
    this.createdAt,
    this.updatedAt,
  });

  Recipe copyWith({
    String? id,
    RecipeName? name,
    RecipeDescription? description,
    List<String>? ingredients,
    int? calories,
    MealType? mealType,
    List<String>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
