import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

/// Enumeración de los tipos de comida del día.
///
/// Define las 4 comidas principales que componen el plan alimenticio diario.
enum MealType { breakfast, lunch, dinner, snack }

/// Entidad que representa una receta completa con instrucciones.
///
/// Contiene toda la información necesaria para preparar un plato:
/// - Nombre e descripción
/// - Lista de ingredientes
/// - Pasos de preparación
/// - Información nutricional (calorías)
/// - Tipo de comida al que pertenece
///
/// Las recetas son generadas por IA o pueden ser predefinidas.
class Recipe {
  /// ID único de la receta.
  final String id;

  /// Nombre de la receta (validado por RecipeName value object).
  final RecipeName name;

  /// Descripción breve del plato (validado por RecipeDescription).
  final RecipeDescription description;

  /// Lista de ingredientes con cantidades (ej: "200g de pollo").
  final List<String> ingredients;

  /// Calorías totales de la receta.
  final int calories;

  /// Tipo de comida (desayuno, comida, cena o snack).
  final MealType mealType;

  /// Pasos de preparación ordenados.
  final List<String> steps;

  /// Timestamp de creación (opcional).
  final DateTime? createdAt;

  /// Timestamp de última actualización (opcional).
  final DateTime? updatedAt;

  /// Crea una instancia de [Recipe].
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
