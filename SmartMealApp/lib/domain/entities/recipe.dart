import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

enum MealType { breakfast, lunch, dinner, snack }
enum DifficultyLevel { easy, medium, hard }

class Recipe {
  final String id;
  final RecipeName name;
  final RecipeDescription description;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int preparationTimeMinutes;
  final int cookingTimeMinutes;
  final int servings;
  final int calories;
  final MealType mealType;
  final DifficultyLevel difficulty;
  final List<String> tags; // vegetariano, vegano, sin gluten, etc.
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.preparationTimeMinutes,
    required this.cookingTimeMinutes,
    required this.servings,
    required this.calories,
    required this.mealType,
    required this.difficulty,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  String get nameValue => name.value;
  String get descriptionValue => description.value;
  int get totalTimeMinutes => preparationTimeMinutes + cookingTimeMinutes;

  Recipe copyWith({
    String? id,
    RecipeName? name,
    RecipeDescription? description,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? steps,
    int? preparationTimeMinutes,
    int? cookingTimeMinutes,
    int? servings,
    int? calories,
    MealType? mealType,
    DifficultyLevel? difficulty,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}