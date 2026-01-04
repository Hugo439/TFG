import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/datasources/remote/gemini_recipe_steps_extension.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';
import 'package:smartmeal/data/datasources/remote/gemini_menu_datasource.dart';
import 'package:smartmeal/data/mappers/ai_menu_mapper.dart';

// Modelos Groq para validar la respuesta cruda
import 'package:smartmeal/data/models/ai_menu_response_model.dart';
import 'package:smartmeal/data/models/recipe_data_model.dart';
import 'package:smartmeal/data/models/day_menu_data_model.dart';

/// Implementación del repositorio de generación de menús con IA.
///
/// Coordina la generación de menús semanales usando Gemini API con:
/// - **Validación robusta**: Verifica que la respuesta de IA sea válida
/// - **Reintentos**: Hasta 2 intentos si la respuesta es inválida
/// - **Sanitización**: Corrige índices fuera de rango y tipos de comida incorrectos
/// - **Generación de pasos**: Asegura que todas las recetas tengan pasos de preparación
///
/// Proceso de generación:
/// 1. Solicitar menú semanal a Gemini (28 recetas: 7 días × 4 comidas)
/// 2. Validar estructura (7 días, 4 comidas/día, sin duplicados, tipos correctos)
/// 3. Si inválida, reintentar (máximo 2 veces)
/// 4. Sanitizar respuesta (corregir índices y tipos)
/// 5. Generar pasos para recetas que no los tengan
/// 6. Mapear a entidad WeeklyMenu
///
/// Criterios de validación:
/// - Exactamente 7 días (lunes a domingo)
/// - 4 comidas por día (breakfast, lunch, snack, dinner)
/// - Índices de recetas válidos (0 a recipes.length-1)
/// - Sin índices duplicados en un mismo día
/// - Tipos de comida correctos (breakfast en breakfast, lunch en lunch, etc.)
class MenuGenerationRepositoryImpl implements MenuGenerationRepository {
  final GeminiMenuDatasource _geminiDatasource;

  MenuGenerationRepositoryImpl(this._geminiDatasource);

  /// Genera un menú semanal completo usando IA.
  ///
  /// Parámetros:
  /// [userId] - ID del usuario para quien se genera el menú.
  /// [targetCaloriesPerDay] - Calorías objetivo por día (se dividirán entre 4 comidas).
  /// [allergies] - Lista de alergias/ingredientes a excluir.
  /// [userGoal] - Objetivo del usuario: 'lose_weight', 'maintain_weight', 'gain_weight', 'gain_muscle'.
  ///
  /// Returns: Menú semanal con 28 recetas (7 días × 4 comidas).
  ///
  /// Proceso:
  /// 1. Calcular calorías por comida (targetCaloriesPerDay / 4)
  /// 2. Solicitar menú a Gemini (máximo 3 intentos)
  /// 3. Validar estructura de respuesta
  /// 4. Sanitizar índices y tipos de comida
  /// 5. Generar pasos para recetas sin pasos
  /// 6. Crear entidad WeeklyMenu con nombre y fechas
  ///
  /// Throws: [ServerFailure] si la IA falla o la respuesta es inválida después de reintentos.
  ///
  /// Nota: Los logs de validación solo se imprimen en debug mode.
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

    // Asegurar que TODAS las recetas tengan pasos
    for (final recipe in sanitizedResponse.recipes) {
      if (recipe.steps.isEmpty) {
        try {
          final steps = await _geminiDatasource.generateRecipeSteps(
            recipeName: recipe.name,
            ingredients: recipe.ingredients,
            description: recipe.description,
          );
          recipe.steps.addAll(steps);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[GeminiMenu] Error generando pasos para "${recipe.name}": $e',
            );
          }
        }
      }
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final menuName =
        'Menú Semanal ${weekStart.day}/${weekStart.month}/${weekStart.year}';

    return AiMenuMapper.toEntity(
      model: sanitizedResponse,
      userId: userId,
      menuName: menuName,
      weekStart: weekStart,
    );
  }

  /// Sanitiza un menú semanal corrigiendo índices y tipos de comida.
  ///
  /// Correcciones aplicadas:
  /// - Índices fuera de rango (< 0 o >= recipes.length) se reemplazan
  /// - Tipos de comida incorrectos se corrigen (breakfast debe ser breakfast, etc.)
  /// - Índices duplicados en un día se reemplazan
  /// - Comidas faltantes se rellenan con índices disponibles
  ///
  /// [model] - Modelo con la respuesta cruda de IA.
  ///
  /// Returns: Modelo sanitizado con todos los días válidos.
  ///
  /// Algoritmo:
  /// 1. Agrupar recetas por tipo (breakfast, lunch, snack, dinner)
  /// 2. Para cada día y comida:
  ///    - Si índice inválido o tipo incorrecto, buscar reemplazo del tipo correcto
  ///    - Evitar índices duplicados en el mismo día
  ///    - Si no hay recetas del tipo, usar fallback (cualquier receta disponible)
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
    final dayOrder = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

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

  /// Valida que un menú semanal tenga la estructura correcta.
  ///
  /// Criterios:
  /// - Exactamente 7 días (lunes a domingo)
  /// - Cada día tiene 4 comidas válidas (breakfast, lunch, snack, dinner)
  ///
  /// [model] - Modelo a validar.
  ///
  /// Returns: `true` si el menú es válido, `false` en caso contrario.
  bool _isValidWeeklyMenu(AiMenuResponseModel model) {
    final recipes = model.recipes;
    final days = model.weeklyMenu;
    final expectedDays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    for (final d in expectedDays) {
      final dayData = days[d];
      if (dayData == null) return false;
      if (!_isValidDay(dayData, recipes)) return false;
    }
    return true;
  }

  /// Valida que un día tenga 4 comidas válidas.
  ///
  /// Criterios:
  /// - Todas las comidas (breakfast, lunch, snack, dinner) tienen índice
  /// - Índices dentro de rango (0 a recipes.length-1)
  /// - Sin índices duplicados
  /// - Tipos de comida correctos (breakfast es breakfast, lunch es lunch, etc.)
  ///
  /// [day] - Datos del día a validar.
  /// [recipes] - Lista de recetas disponibles.
  ///
  /// Returns: `true` si el día es válido.
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

  /// Imprime detalles de un menú inválido (solo en debug mode).
  ///
  /// Reporta:
  /// - Días faltantes
  /// - Comidas faltantes en cada día
  /// - Índices fuera de rango
  /// - Tipos de comida incorrectos
  /// - Índices duplicados
  ///
  /// [model] - Modelo inválido a analizar.
  ///
  /// Nota: Solo para debugging durante desarrollo.
  void _logInvalidWeeklyMenu(AiMenuResponseModel model) {
    final recipes = model.recipes;
    final days = model.weeklyMenu;
    final expectedDays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

    for (final d in expectedDays) {
      final dayData = days[d];
      if (dayData == null) {
        debugPrint(' - Día "$d" ausente en weeklyMenu');
        continue;
      }
      final indices = <int?>[
        dayData.breakfast,
        dayData.lunch,
        dayData.snack,
        dayData.dinner,
      ];
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
          debugPrint(
            ' - Día "$d": $label apunta a receta tipo "$type" (índice $idx)',
          );
        }
      }

      final nonNull = indices.whereType<int>().toList();
      if (nonNull.toSet().length != nonNull.length) {
        debugPrint(' - Día "$d": índices duplicados $nonNull');
      }
    }
  }

  /// Genera pasos de preparación para una receta usando IA.
  ///
  /// [recipeName] - Nombre de la receta.
  /// [ingredients] - Lista de ingredientes de la receta.
  /// [description] - Descripción breve de la receta.
  ///
  /// Returns: Lista de pasos de preparación en orden.
  ///
  /// Throws: Errores de la IA se propagan al llamador.
  ///
  /// Nota: Usado cuando las recetas generadas no incluyen pasos o cuando
  /// el usuario solicita regenerar los pasos.
  @override
  Future<List<String>> generateRecipeSteps({
    required String recipeName,
    required List<String> ingredients,
    required String description,
  }) async {
    return await _geminiDatasource.generateRecipeSteps(
      recipeName: recipeName,
      ingredients: ingredients,
      description: description,
    );
  }
}
