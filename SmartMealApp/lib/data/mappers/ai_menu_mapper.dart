import 'package:smartmeal/data/models/ai_menu_response_model.dart';
import 'package:smartmeal/data/models/recipe_data_model.dart';
import 'package:smartmeal/data/models/day_menu_data_model.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

/// Mapper complejo para convertir respuesta de IA en WeeklyMenu del dominio.
///
/// Responsabilidades:
/// - **toEntity**: Convierte AiMenuResponseModel (JSON de IA) → WeeklyMenu completo
/// - **_mapRecipes**: Transforma RecipeDataModel[] → Recipe[] con IDs únicos
/// - **_mapDays**: Construye DayMenu[] resolviendo índices a recetas reales
/// - **_parseMealType**: Convierte string → MealType enum
///
/// Proceso de conversión:
/// 1. Crear 28 entidades Recipe desde RecipeDataModel con IDs únicos
/// 2. Para cada día de la semana:
///    - Extraer índices de recetas desde DayMenuDataModel
///    - Construir mapa mealType → índice
///    - Resolver índices faltantes buscando recetas del tipo correcto no usadas
///    - Crear DayMenu con 4 recetas (breakfast, lunch, snack, dinner)
/// 3. Construir WeeklyMenu con ID único, fechas y estadísticas
///
/// Manejo de errores:
/// - Si faltan índices, busca recetas del tipo apropiado que no se hayan usado
/// - Si un índice está fuera de rango, intenta encontrar reemplazo
/// - Garantiza que cada día tenga 4 recetas distintas
///
/// Formato de ID generado:
/// - Menu: {userId}_menu_{timestamp}
/// - Recipe: {userId}_recipe_{timestamp}_{index}
class AiMenuMapper {
  /// Convierte respuesta de IA en WeeklyMenu del dominio.
  ///
  /// [model] - Respuesta parseada desde Gemini/Groq (28 recetas + distribución semanal).
  /// [userId] - ID del usuario para generar IDs únicos de recetas y menú.
  /// [menuName] - Nombre del menú (ej: "Menú perder peso Semana 1").
  /// [weekStart] - Fecha de inicio de la semana (lunes).
  ///
  /// Returns: WeeklyMenu completo con:
  /// - 28 recetas (4 por día × 7 días)
  /// - 7 DayMenu con recetas asignadas por tipo de comida
  /// - IDs únicos basados en userId y timestamp
  ///
  /// Proceso:
  /// 1. Mapea 28 RecipeDataModel → Recipe entities con IDs únicos
  /// 2. Para cada día, mapea DayMenuDataModel → DayMenu con 4 recetas
  /// 3. Resuelve índices faltantes buscando recetas apropiadas
  /// 4. Crea WeeklyMenu con metadatos
  static WeeklyMenu toEntity({
    required AiMenuResponseModel model,
    required String userId,
    required String menuName,
    required DateTime weekStart,
  }) {
    // Convertir RecipeDataModel → Recipe entities
    final recipes = _mapRecipes(model.recipes, userId);

    // Convertir DayMenuDataModel → DayMenu entities
    final days = _mapDays(model.weeklyMenu, recipes);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return WeeklyMenu(
      id: '${userId}_menu_$timestamp',
      userId: userId,
      name: menuName,
      weekStartDate: weekStart,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  /// Convierte lista de RecipeDataModel a entidades Recipe del dominio.
  ///
  /// [recipesData] - Lista de 28 recetas desde JSON de IA.
  /// [userId] - ID del usuario para generar IDs únicos.
  ///
  /// Returns: Lista de Recipe con Value Objects validados.
  ///
  /// Formato ID: {userId}_recipe_{timestamp}_{index}
  /// Ejemplo: "user123_recipe_1704124800000_0"
  static List<Recipe> _mapRecipes(
    List<RecipeDataModel> recipesData,
    String userId,
  ) {
    final recipes = <Recipe>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < recipesData.length; i++) {
      final recipeData = recipesData[i];
      recipes.add(
        Recipe(
          id: '${userId}_recipe_${timestamp}_$i',
          name: RecipeName(recipeData.name),
          description: RecipeDescription(recipeData.description),
          ingredients: recipeData.ingredients,
          calories: recipeData.calories,
          mealType: _parseMealType(recipeData.mealType),
          steps: recipeData.steps,
          createdAt: DateTime.now(),
        ),
      );
    }
    return recipes;
  }

  /// Construye 7 DayMenu resolviendo índices de recetas desde datos de IA.
  ///
  /// [weeklyMenuData] - Mapa día → DayMenuDataModel con índices de recetas.
  /// [recipes] - Pool de 28 recetas disponibles.
  ///
  /// Returns: Lista de 7 DayMenu con 4 recetas cada uno.
  ///
  /// Algoritmo de asignación:
  /// 1. **Extraer índices declarados**: Lee getRecipeIndicesInOrder() del modelo
  /// 2. **Mapear por tipo de comida**: breakfast → lunch → snack → dinner
  /// 3. **Resolver faltantes**: Si un índice falta o es inválido:
  ///    - Busca receta del tipo apropiado (MealType) no usada aún
  ///    - Marca como usada para evitar duplicados en el mismo día
  /// 4. **Fallback**: Si no encuentra del tipo correcto, usa cualquier receta disponible
  ///
  /// Restricción: Cada día debe tener 4 recetas distintas (no repetir índices).
  ///
  /// Ejemplo:
  /// - Día lunes recibe índices [0, 7, 14, 21] (breakfast, lunch, snack, dinner)
  /// - Si falta snack (índice 14), busca receta con mealType=snack no usada
  static List<DayMenu> _mapDays(
    Map<String, DayMenuDataModel> weeklyMenuData,
    List<Recipe> recipes,
  ) {
    final days = <DayMenu>[];
    final dayNames = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

    for (int i = 0; i < dayNames.length; i++) {
      final dayName = dayNames[i];
      final dayData = weeklyMenuData[dayName];

      // Paso 1: extraer índices en orden declarativo del modelo
      final rawIndices = dayData?.getRecipeIndicesInOrder() ?? <int>[];

      // Paso 2: construir mapa de comida → índice (permitiendo ausencias con null)
      final Map<String, int?> mealIndexByType = {};
      final mealOrder = ['breakfast', 'lunch', 'snack', 'dinner'];

      for (int j = 0; j < rawIndices.length && j < mealOrder.length; j++) {
        final idx = rawIndices[j];
        final meal = mealOrder[j];
        if (!mealIndexByType.containsKey(meal) &&
            idx >= 0 &&
            idx < recipes.length) {
          mealIndexByType[meal] = idx;
        }
      }

      // Paso 3: resolver faltantes usando recetas del tipo correspondiente no usadas
      final usedIndices = <int>{...mealIndexByType.values.whereType<int>()};

      int findRecipeIndexForMeal(MealType type) {
        for (int k = 0; k < recipes.length; k++) {
          if (!usedIndices.contains(k) && recipes[k].mealType == type) {
            return k;
          }
        }
        return -1; // no encontrada
      }

      // breakfast
      mealIndexByType.putIfAbsent('breakfast', () {
        final idx = findRecipeIndexForMeal(MealType.breakfast);
        return idx >= 0 ? idx : null;
      });

      // lunch
      mealIndexByType.putIfAbsent('lunch', () {
        final idx = findRecipeIndexForMeal(MealType.lunch);
        return idx >= 0 ? idx : null;
      });

      // snack
      mealIndexByType.putIfAbsent('snack', () {
        final idx = findRecipeIndexForMeal(MealType.snack);
        return idx >= 0 ? idx : null;
      });

      // dinner
      mealIndexByType.putIfAbsent('dinner', () {
        final idx = findRecipeIndexForMeal(MealType.dinner);
        return idx >= 0 ? idx : null;
      });

      // Paso 4: construir las recetas finales en el orden fijo
      final dayRecipes = <Recipe>[];
      for (final meal in mealOrder) {
        final idx = mealIndexByType[meal];
        if (idx != null && idx >= 0 && idx < recipes.length) {
          dayRecipes.add(recipes[idx]);
          usedIndices.add(idx);
        } else {
          // Fallback: cualquier receta disponible no usada
          final fallbackIdx = recipes.indexWhere((r) {
            final candidateIdx = recipes.indexOf(r);
            return !usedIndices.contains(candidateIdx);
          });
          if (fallbackIdx != -1) {
            dayRecipes.add(recipes[fallbackIdx]);
            usedIndices.add(fallbackIdx);
          }
        }
      }

      days.add(DayMenu(day: _parseDayOfWeek(i), recipes: dayRecipes));
    }

    return days;
  }

  /// Convierte string de tipo de comida a enum MealType.
  ///
  /// [type] - String desde JSON de IA: "breakfast", "lunch", "dinner", "snack".
  ///
  /// Returns: MealType correspondiente, default snack si no reconoce.
  static MealType _parseMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.snack;
    }
  }

  /// Convierte índice de día (0-6) a enum DayOfWeek.
  ///
  /// [index] - Índice del día: 0=lunes, 1=martes, ..., 6=domingo.
  ///
  /// Returns: DayOfWeek correspondiente, default monday si índice inválido.
  static DayOfWeek _parseDayOfWeek(int index) {
    switch (index) {
      case 0:
        return DayOfWeek.monday;
      case 1:
        return DayOfWeek.tuesday;
      case 2:
        return DayOfWeek.wednesday;
      case 3:
        return DayOfWeek.thursday;
      case 4:
        return DayOfWeek.friday;
      case 5:
        return DayOfWeek.saturday;
      case 6:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }
}
