import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

class RecipeModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int preparationTimeMinutes;
  final int cookingTimeMinutes;
  final int servings;
  final int calories;
  final String mealType;
  final String difficulty;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecipeModel({
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

  // Convertir de Firestore a Modelo
  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      preparationTimeMinutes: data['preparationTimeMinutes'] ?? 0,
      cookingTimeMinutes: data['cookingTimeMinutes'] ?? 0,
      servings: data['servings'] ?? 1,
      calories: data['calories'] ?? 0,
      mealType: data['mealType'] ?? 'lunch',
      difficulty: data['difficulty'] ?? 'medium',
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'preparationTimeMinutes': preparationTimeMinutes,
      'cookingTimeMinutes': cookingTimeMinutes,
      'servings': servings,
      'calories': calories,
      'mealType': mealType,
      'difficulty': difficulty,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convertir de Modelo a Entidad
  Recipe toEntity() {
    return Recipe(
      id: id,
      name: RecipeName(name),
      description: RecipeDescription(description),
      imageUrl: imageUrl,
      ingredients: ingredients,
      steps: steps,
      preparationTimeMinutes: preparationTimeMinutes,
      cookingTimeMinutes: cookingTimeMinutes,
      servings: servings,
      calories: calories,
      mealType: _parseMealType(mealType),
      difficulty: _parseDifficulty(difficulty),
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convertir de Entidad a Modelo
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.nameValue,
      description: recipe.descriptionValue,
      imageUrl: recipe.imageUrl,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      preparationTimeMinutes: recipe.preparationTimeMinutes,
      cookingTimeMinutes: recipe.cookingTimeMinutes,
      servings: recipe.servings,
      calories: recipe.calories,
      mealType: recipe.mealType.name,
      difficulty: recipe.difficulty.name,
      tags: recipe.tags,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
    );
  }

  static MealType _parseMealType(String value) {
    return MealType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MealType.lunch,
    );
  }

  static DifficultyLevel _parseDifficulty(String value) {
    return DifficultyLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DifficultyLevel.medium,
    );
  }
}