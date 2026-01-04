import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';
import 'package:smartmeal/core/utils/meal_type_utils.dart';

/// Modelo de datos para Recipe compatible con Firestore.
///
/// Responsabilidades:
/// - Serialización/deserialización desde/hacia Firestore
/// - Conversión a entidad Recipe del dominio
/// - Almacenar datos primitivos (sin Value Objects)
///
/// Campos:
/// - **id**: ID único (userId_recipe_timestamp_index)
/// - **name**: nombre de la receta (string)
/// - **description**: descripción breve
/// - **ingredients**: lista de ingredientes con cantidades
/// - **calories**: calorías totales
/// - **mealType**: tipo de comida (breakfast, lunch, dinner, snack)
/// - **steps**: pasos de preparación
/// - **createdAt, updatedAt**: timestamps
///
/// Conversiones:
/// - **fromFirestore**: DocumentSnapshot → RecipeModel
/// - **toEntity**: RecipeModel → Recipe (con Value Objects)
/// - **toFirestore**: RecipeModel → Map para persistencia
///
/// Ejemplo Firestore:
/// ```json
/// {
///   "name": "Pollo al horno",
///   "description": "Pollo asado con hierbas",
///   "ingredients": ["500g pollo", "2 dientes ajo", "aceite oliva"],
///   "calories": 450,
///   "mealType": "lunch",
///   "steps": ["Precalentar horno", "Sazonar pollo", "Hornear 45min"],
///   "createdAt": "2024-01-01T10:00:00.000Z",
///   "updatedAt": "2024-01-05T15:30:00.000Z"
/// }
/// ```
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

  /// Crea RecipeModel desde DocumentSnapshot de Firestore.
  ///
  /// Maneja campos faltantes con valores por defecto.
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

  /// Convierte modelo a entidad del dominio con Value Objects.
  ///
  /// Crea RecipeName y RecipeDescription validados.
  /// Convierte mealType string a enum MealType.
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

  /// Convierte modelo a Map para persistencia en Firestore.
  ///
  /// No incluye 'id' porque Firestore usa document ID.
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
