import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';
import 'package:smartmeal/data/datasources/remote/gemini_menu_datasource.dart';
import 'package:smartmeal/data/mappers/ai_menu_mapper.dart';

// Modelos Groq para validar la respuesta cruda
import 'package:smartmeal/data/models/ai_menu_response_model.dart';
import 'package:smartmeal/data/models/recipe_data_model.dart';
import 'package:smartmeal/data/models/day_menu_data_model.dart';

class MenuGenerationRepositoryImpl implements MenuGenerationRepository {
  final GeminiMenuDatasource _geminiDatasource;

  MenuGenerationRepositoryImpl(this._geminiDatasource);

  @override
  Future<WeeklyMenu> generateWeeklyMenu({
    required String userId,
    required int targetCaloriesPerDay,
    required List<String> allergies,
    required String userGoal,
  }) async {
    final caloriesPerMeal = (targetCaloriesPerDay / 4).round();

    const maxRetries = 2;
    AiMenuResponseModel response;
    int attempt = 0;

    while (true) {
      response = await _geminiDatasource.generateWeeklyMenu(
        targetCaloriesPerMeal: caloriesPerMeal,
        excludedTags: allergies,
        userGoal: userGoal,
        recipesCount: 28,
      );

      final isValid = _isValidWeeklyMenu(response);
      if (isValid) break;

      if (kDebugMode) {
        debugPrint('[GeminiMenu] Respuesta inválida en intento #$attempt');
        _logInvalidWeeklyMenu(response);
      }

      if (attempt >= maxRetries) break;
      attempt++;
    }

    // Saneado por tipo/rango/duplicados antes de mapear
    final sanitizedResponse = _sanitizeWeeklyMenu(response);

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final menuName = 'Menú Semanal ${weekStart.day}/${weekStart.month}/${weekStart.year}';

    return AiMenuMapper.toEntity(
      model: sanitizedResponse,
      userId: userId,
      menuName: menuName,
      weekStart: weekStart,
    );
  }

  AiMenuResponseModel _sanitizeWeeklyMenu(AiMenuResponseModel model) {
    final recipes = model.recipes;
    final mealTypeToIndices = <String, List<int>>{
      'breakfast': [],
      'lunch': [],
      'snack': [],
      'dinner': [],
    };

    for (int i = 0; i < recipes.length; i++) {
      final t = recipes[i].mealType.toLowerCase();
      if (mealTypeToIndices.containsKey(t)) {
        mealTypeToIndices[t]!.add(i);
      }
    }

    int? pickIndexFor(String type, Set<int> used) {
      final list = mealTypeToIndices[type]!;
      for (final idx in list) {
        if (!used.contains(idx)) return idx;
      }
      return null;
    }

    final sanitized = Map<String, DayMenuDataModel>.from(model.weeklyMenu);
    final dayOrder = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

    for (final day in dayOrder) {
      final original = sanitized[day];
      final used = <int>{};

      int? b = original?.breakfast;
      int? l = original?.lunch;
      int? s = original?.snack;
      int? d = original?.dinner;

      bool inRange(int? idx) => idx != null && idx >= 0 && idx < recipes.length;

      if (!inRange(b) || recipes[b!].mealType.toLowerCase() != 'breakfast') {
        b = pickIndexFor('breakfast', used);
      }
      if (b != null) used.add(b);

      if (!inRange(l) || recipes[l!].mealType.toLowerCase() != 'lunch') {
        l = pickIndexFor('lunch', used);
      }
      if (l != null) used.add(l);

      if (!inRange(s) || recipes[s!].mealType.toLowerCase() != 'snack') {
        s = pickIndexFor('snack', used);
      }
      if (s != null) used.add(s);

      if (!inRange(d) || recipes[d!].mealType.toLowerCase() != 'dinner') {
        d = pickIndexFor('dinner', used);
      }
      if (d != null) used.add(d);

      int? fallback(Set<int> usedSet) {
        for (int i = 0; i < recipes.length; i++) {
          if (!usedSet.contains(i)) return i;
        }
        return null;
      }

      b ??= pickIndexFor('breakfast', used) ?? fallback(used);
      if (b != null) used.add(b);
      l ??= pickIndexFor('lunch', used) ?? fallback(used);
      if (l != null) used.add(l);
      s ??= pickIndexFor('snack', used) ?? fallback(used);
      if (s != null) used.add(s);
      d ??= pickIndexFor('dinner', used) ?? fallback(used);
      if (d != null) used.add(d);

      sanitized[day] = DayMenuDataModel(
        breakfast: b,
        lunch: l,
        snack: s,
        dinner: d,
      );
    }

    return AiMenuResponseModel(recipes: recipes, weeklyMenu: sanitized);
  }

  bool _isValidWeeklyMenu(AiMenuResponseModel model) {
    final recipes = model.recipes;
    final days = model.weeklyMenu;
    final expectedDays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    for (final d in expectedDays) {
      final dayData = days[d];
      if (dayData == null) return false;
      if (!_isValidDay(dayData, recipes)) return false;
    }
    return true;
  }

  bool _isValidDay(DayMenuDataModel day, List<RecipeDataModel> recipes) {
    final indices = <int>[
      day.breakfast ?? -1,
      day.lunch ?? -1,
      day.snack ?? -1,
      day.dinner ?? -1,
    ];
    if (indices.any((i) => i < 0)) return false;
    if (indices.any((i) => i >= recipes.length)) return false;
    if (indices.toSet().length != 4) return false;

    final types = ['breakfast', 'lunch', 'snack', 'dinner'];
    for (int i = 0; i < 4; i++) {
      final recipe = recipes[indices[i]];
      if (recipe.mealType.toLowerCase() != types[i]) return false;
    }
    return true;
  }

  void _logInvalidWeeklyMenu(AiMenuResponseModel model) {
    final recipes = model.recipes;
    final days = model.weeklyMenu;
    final expectedDays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

    for (final d in expectedDays) {
      final dayData = days[d];
      if (dayData == null) {
        debugPrint(' - Día "$d" ausente en weeklyMenu');
        continue;
      }
      final indices = <int?>[dayData.breakfast, dayData.lunch, dayData.snack, dayData.dinner];
      final labels = ['breakfast', 'lunch', 'snack', 'dinner'];

      for (int i = 0; i < indices.length; i++) {
        final idx = indices[i];
        final label = labels[i];

        if (idx == null) {
          debugPrint(' - Día "$d": falta $label');
          continue;
        }
        if (idx < 0 || idx >= recipes.length) {
          debugPrint(' - Día "$d": $label índice fuera de rango ($idx)');
          continue;
        }
        final type = recipes[idx].mealType.toLowerCase();
        if (type != label) {
          debugPrint(' - Día "$d": $label apunta a receta tipo "$type" (índice $idx)');
        }
      }

      final nonNull = indices.whereType<int>().toList();
      if (nonNull.toSet().length != nonNull.length) {
        debugPrint(' - Día "$d": índices duplicados $nonNull');
      }
    }
  }
}