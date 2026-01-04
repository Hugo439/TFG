import 'package:smartmeal/data/models/recipe_data_model.dart';
import 'package:smartmeal/data/models/day_menu_data_model.dart';

/// Modelo para respuesta JSON de IA (Gemini/Groq) al generar menú.
///
/// Responsabilidades:
/// - Parsear respuesta JSON de API de IA
/// - Contener 28 recetas + distribución semanal
///
/// Estructura:
/// - **recipes**: lista de 28 RecipeDataModel (4 por día × 7 días)
/// - **weeklyMenu**: mapa día → DayMenuDataModel con índices de recetas
///
/// Formato JSON esperado:
/// ```json
/// {
///   "recipes": [
///     {"name": "Avena", "mealType": "breakfast", "calories": 300, ...},
///     {"name": "Pollo", "mealType": "lunch", "calories": 450, ...},
///     ... (28 recetas)
///   ],
///   "weeklyMenu": {
///     "lunes": {"breakfast": 0, "lunch": 4, "snack": 8, "dinner": 12},
///     "martes": {"breakfast": 1, "lunch": 5, "snack": 9, "dinner": 13},
///     ...
///   }
/// }
/// ```
///
/// Los índices en weeklyMenu referencian posiciones en el array recipes.
///
/// Uso:
/// 1. IA genera JSON con este formato
/// 2. AiMenuResponseModel.fromJson() parsea el JSON
/// 3. AiMenuMapper.toEntity() convierte a WeeklyMenu del dominio
class AiMenuResponseModel {
  final List<RecipeDataModel> recipes;
  final Map<String, DayMenuDataModel> weeklyMenu;

  AiMenuResponseModel({required this.recipes, required this.weeklyMenu});

  /// Parsea JSON de respuesta de IA.
  ///
  /// Convierte:
  /// - Array 'recipes' → List<RecipeDataModel>
  /// - Objeto 'weeklyMenu' → Map<String, DayMenuDataModel>
  factory AiMenuResponseModel.fromJson(Map<String, dynamic> json) {
    final recipesJson = json['recipes'] as List;
    final recipes = recipesJson
        .map((r) => RecipeDataModel.fromJson(r as Map<String, dynamic>))
        .toList();

    final weeklyMenuJson = json['weeklyMenu'] as Map<String, dynamic>;
    final weeklyMenu = <String, DayMenuDataModel>{};

    weeklyMenuJson.forEach((day, data) {
      weeklyMenu[day] = DayMenuDataModel.fromJson(data as Map<String, dynamic>);
    });

    return AiMenuResponseModel(recipes: recipes, weeklyMenu: weeklyMenu);
  }
}
