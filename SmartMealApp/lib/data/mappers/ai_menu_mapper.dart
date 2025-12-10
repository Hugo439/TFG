import 'package:smartmeal/data/models/ai_menu_response_model.dart';
import 'package:smartmeal/data/models/recipe_data_model.dart';
import 'package:smartmeal/data/models/day_menu_data_model.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';

class AiMenuMapper {
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

  static List<Recipe> _mapRecipes(List<RecipeDataModel> recipesData, String userId) {
    final recipes = <Recipe>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < recipesData.length; i++) {
      final recipeData = recipesData[i];
      recipes.add(Recipe(
        id: '${userId}_recipe_${timestamp}_$i',
        name: RecipeName(recipeData.name),
        description: RecipeDescription(recipeData.description),
        ingredients: recipeData.ingredients,
        calories: recipeData.calories,
        mealType: _parseMealType(recipeData.mealType),
        createdAt: DateTime.now(),
      ));
    }
    return recipes;
  }

  static List<DayMenu> _mapDays(
    Map<String, DayMenuDataModel> weeklyMenuData,
    List<Recipe> recipes,
  ) {
    final days = <DayMenu>[];
    final dayNames = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

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
        if (!mealIndexByType.containsKey(meal) && idx >= 0 && idx < recipes.length) {
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

      days.add(DayMenu(
        day: _parseDayOfWeek(i),
        recipes: dayRecipes,
      ));
    }

    return days;
  }

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

  static DayOfWeek _parseDayOfWeek(int index) {
    switch (index) {
      case 0: return DayOfWeek.monday;
      case 1: return DayOfWeek.tuesday;
      case 2: return DayOfWeek.wednesday;
      case 3: return DayOfWeek.thursday;
      case 4: return DayOfWeek.friday;
      case 5: return DayOfWeek.saturday;
      case 6: return DayOfWeek.sunday;
      default: return DayOfWeek.monday;
    }
  }
}