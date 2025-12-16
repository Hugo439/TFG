import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';
import 'package:smartmeal/core/utils/meal_type_utils.dart';

class RecipeModel {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final int calories;
  final String mealType;
  final List<String> steps;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecipeModel({
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

  // Convertir de Firestore a Modelo
  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      calories: data['calories'] ?? 0,
      mealType: data['mealType'] ?? 'breakfast',
      steps: List<String>.from(data['steps'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convertir de Modelo a Entidad
  Recipe toEntity() => Recipe(
    id: id,
    name: RecipeName(name),
    description: RecipeDescription(description),
    ingredients: ingredients,
    calories: calories,
    mealType: mealTypeFromString(mealType),
    steps: steps,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'ingredients': ingredients,
    'calories': calories,
    'mealType': mealType,
    'steps': steps,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}