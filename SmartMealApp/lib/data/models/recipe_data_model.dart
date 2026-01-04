/// Modelo de datos para receta desde respuesta de IA.
///
/// Responsabilidad:
/// - Parsear receta individual desde JSON de IA
///
/// Campos:
/// - **name**: nombre de la receta
/// - **description**: descripción breve
/// - **ingredients**: lista de ingredientes con cantidades
/// - **calories**: calorías totales
/// - **mealType**: tipo de comida (breakfast, lunch, dinner, snack)
/// - **steps**: pasos de preparación (puede estar vacío)
///
/// Formato JSON esperado:
/// ```json
/// {
///   "name": "Pollo al horno con verduras",
///   "description": "Pollo asado con pimientos y cebolla",
///   "ingredients": ["500g pollo", "2 pimientos", "1 cebolla"],
///   "calories": 450,
///   "mealType": "lunch",
///   "steps": ["Precalentar horno", "Cortar verduras", "Hornear 45min"]
/// }
/// ```
///
/// Diferencia con RecipeModel:
/// - **RecipeDataModel**: datos crudos desde IA (sin ID, sin timestamps)
/// - **RecipeModel**: modelo completo para Firestore (con ID, timestamps)
class RecipeDataModel {
  final String name;
  final String description;
  final List<String> ingredients;
  final int calories;
  final String mealType;
  final List<String> steps;

  RecipeDataModel({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.mealType,
    required this.steps,
  });

  /// Parsea receta desde JSON de IA.
  ///
  /// Maneja steps opcional (default []).
  factory RecipeDataModel.fromJson(Map<String, dynamic> json) {
    return RecipeDataModel(
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List)
          .map((e) => e.toString())
          .toList(),
      calories: json['calories'] as int,
      mealType: json['mealType'] as String,
      steps: (json['steps'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
