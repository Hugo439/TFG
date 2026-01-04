import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/statistics_repository.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_category.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';
import 'package:smartmeal/domain/value_objects/statistics_models.dart';
import 'package:smartmeal/data/models/statistics_cache_model.dart';
import 'package:smartmeal/data/datasources/local/statistics_local_datasource.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Implementación del repositorio de estadísticas.
///
/// Calcula y cachea estadísticas nutricionales y de uso:
/// - **Conteo de comidas**: Cuántas veces se usó cada tipo (breakfast, lunch, snack, dinner)
/// - **Ingredientes más usados**: Top 6 ingredientes normalizados de la semana
/// - **Recetas más repetidas**: Top 5 recetas de todo el historial
/// - **Calorías**: Total semanal y promedio diario
/// - **Macronutrientes**: Proteínas, carbohidratos y grasas estimadas
/// - **Coste estimado**: Basado en la lista de compras actual
///
/// Características:
/// - **Caché offline-first**: Carga instantánea desde caché local, actualiza en segundo plano
/// - **Estimación de macros**: Usa heurísticas + API USDA + caché en memoria
/// - **Normalización inteligente**: Agrupa variantes del mismo ingrediente
/// - **Parsing de cantidades**: Convierte "200 g" a gramos base para cálculos
///
/// Fuentes de macros (en orden de prioridad):
/// 1. Caché en memoria (API USDA)
/// 2. API USDA (Cloudflare Worker)
/// 3. Heurística local (_macroPer100g: 100+ ingredientes comunes)
/// 4. Fallback por categoría
///
/// Nota: Los cálculos se basan en el menú más reciente.
class StatisticsRepositoryImpl implements StatisticsRepository {
  final WeeklyMenuRepository _weeklyMenuRepository;
  final ShoppingRepository _shoppingRepository;
  final SmartIngredientNormalizer _normalizer;
  final SmartCategoryHelper _categoryHelper;
  final IngredientParser _parser;
  final FirebaseFirestore _firestore;
  final StatisticsLocalDatasource _localDS;
  final Map<String, _MacroProfile> _macroApiCache = {};
  final String _macroWorkerUrl;

  // Macros heurísticos base por 100 g (aprox)
  // Usados cuando no hay datos de API USDA
  // Formato: nombre_normalizado -> (proteína_g, carbohidratos_g, grasas_g)
  static const Map<String, _MacroProfile> _macroPer100g = {
    'pollo': _MacroProfile(31, 0, 4),
    'pavo': _MacroProfile(29, 0, 3),
    'carne': _MacroProfile(26, 0, 15),
    'cerdo': _MacroProfile(25, 0, 20),
    'ternera': _MacroProfile(26, 0, 15),
    'salmon': _MacroProfile(20, 0, 13),
    'atun': _MacroProfile(23, 0, 4),
    'merluza': _MacroProfile(18, 0, 2),
    'bacalao': _MacroProfile(18, 0, 1),
    'gamba': _MacroProfile(19, 0, 1),
    'langostino': _MacroProfile(19, 0, 1),
    'hummus': _MacroProfile(8, 14, 9),
    'garbanzo': _MacroProfile(9, 61, 6),
    'lenteja': _MacroProfile(9, 63, 1),
    'alubia': _MacroProfile(9, 60, 1),
    'quinoa': _MacroProfile(14, 64, 6),
    'arroz': _MacroProfile(3, 77, 1),
    'pasta': _MacroProfile(13, 75, 1.5),
    'avena': _MacroProfile(13, 67, 7),
    'pan': _MacroProfile(9, 49, 4),
    'muesli': _MacroProfile(12, 60, 8),
    'granola': _MacroProfile(10, 65, 10),
    'patata': _MacroProfile(2, 17, 0.1),
    'boniato': _MacroProfile(1.6, 20, 0.1),
    'batata': _MacroProfile(1.6, 20, 0.1),
    'zanahoria': _MacroProfile(0.9, 10, 0.2),
    'tomate': _MacroProfile(0.9, 3.9, 0.2),
    'cebolla': _MacroProfile(1.1, 9, 0.1),
    'calabacin': _MacroProfile(1.2, 3, 0.3),
    'berenjena': _MacroProfile(1, 6, 0.2),
    'brocoli': _MacroProfile(2.8, 7, 0.4),
    'espinaca': _MacroProfile(2.9, 3.6, 0.4),
    'lechuga': _MacroProfile(1.4, 2.9, 0.2),
    'pepino': _MacroProfile(0.7, 3.6, 0.1),
    'pimiento': _MacroProfile(1, 6, 0.3),
    'manzana': _MacroProfile(0.3, 14, 0.2),
    'platano': _MacroProfile(1.1, 23, 0.3),
    'naranja': _MacroProfile(0.9, 12, 0.1),
    'limon': _MacroProfile(1.1, 9, 0.3),
    'fresa': _MacroProfile(0.8, 8, 0.4),
    'frambuesa': _MacroProfile(1.2, 12, 0.6),
    'arandano': _MacroProfile(0.7, 14, 0.3),
    'mango': _MacroProfile(0.8, 15, 0.4),
    'aguacate': _MacroProfile(2, 9, 15),
    'aceite': _MacroProfile(0, 0, 100),
    'mantequilla': _MacroProfile(0.8, 0.1, 81),
    'aceituna': _MacroProfile(1, 6, 15),
    'queso': _MacroProfile(25, 2, 30),
    'yogur': _MacroProfile(4, 5, 2),
    'leche': _MacroProfile(3.3, 5, 3.5),
    'tofu': _MacroProfile(8, 2, 4),
    'tempeh': _MacroProfile(19, 9, 11),
    'soja': _MacroProfile(36, 30, 20),
    'proteina': _MacroProfile(80, 5, 5),
    'harina': _MacroProfile(10, 76, 1),
    'avellana': _MacroProfile(15, 17, 61),
    'nuez': _MacroProfile(15, 14, 65),
    'almendra': _MacroProfile(21, 22, 50),
    'anacardo': _MacroProfile(18, 30, 44),
    'pistacho': _MacroProfile(20, 28, 45),
    'cacahuete': _MacroProfile(26, 16, 49),
    'miel': _MacroProfile(0.3, 82, 0),
  };

  // Macros por unidad para algunos básicos (1 unidad)
  // Usado cuando la cantidad viene en "ud" (unidades)
  // Ejemplo: "2 ud huevo" usaría estos valores × 2
  static const Map<String, _MacroProfile> _macroPerUnit = {
    'huevo': _MacroProfile(6.3, 0.4, 5.3),
    'platano': _MacroProfile(1.3, 27, 0.4),
    'manzana': _MacroProfile(0.5, 25, 0.3),
    'naranja': _MacroProfile(1.2, 15, 0.2),
    'tomate': _MacroProfile(1, 5, 0.2),
    'yogur': _MacroProfile(4, 5, 2), // 1 unidad 125g aprox
  };

  // Fallback por categoría (por 100 g)
  // Usado cuando no se encuentra el ingrediente específico
  // ni en heurísticas ni en API
  static const Map<ShoppingItemCategory, _MacroProfile> _categoryMacroPer100g =
      {
        ShoppingItemCategory.carnesYPescados: _MacroProfile(20, 0, 10),
        ShoppingItemCategory.lacteos: _MacroProfile(6, 5, 6),
        ShoppingItemCategory.frutasYVerduras: _MacroProfile(1, 10, 0.2),
        ShoppingItemCategory.panaderia: _MacroProfile(8, 50, 5),
        ShoppingItemCategory.bebidas: _MacroProfile(1, 5, 0),
        ShoppingItemCategory.snacks: _MacroProfile(15, 30, 20),
        ShoppingItemCategory.otros: _MacroProfile(5, 20, 5),
      };

  StatisticsRepositoryImpl(
    this._weeklyMenuRepository,
    this._shoppingRepository,
    this._normalizer,
    this._categoryHelper, {
    required StatisticsLocalDatasource localDatasource,
    FirebaseFirestore? firestore,
    String? macroWorkerUrl,
    IngredientParser? parser,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _parser = parser ?? IngredientParser(),
       _macroWorkerUrl =
           macroWorkerUrl ??
           'https://groq-worker.smartmealgroq.workers.dev/macros',
       _localDS = localDatasource;

  /// Recalcula y actualiza las estadísticas en segundo plano.
  ///
  /// [userId] - ID del usuario.
  ///
  /// Proceso:
  /// 1. Calcular estadísticas completas
  /// 2. Guardar en caché local para próxima carga instantánea
  ///
  /// Nota: Los errores se silencian para no interferir con la operación principal.
  /// Esta función se llama automáticamente en segundo plano desde [getStatisticsSummary].
  Future<void> refreshStatistics(String userId) async {
    try {
      final summary = await _calculateStatisticsSummary(userId);
      if (summary != null) {
        // Obtener la fecha del menú más reciente
        final allMenus = await _weeklyMenuRepository.getWeeklyMenus(userId);
        if (allMenus.isNotEmpty) {
          allMenus.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
          final menuDate = allMenus.first.weekStartDate;
          await _localDS.saveLatest(
            StatisticsCacheModel.fromSummary(summary, menuDate),
          );
        }
      }
    } catch (e) {
      // Silenciar errores en refresh
    }
  }

  /// Obtiene el resumen de estadísticas del usuario.
  ///
  /// Estrategia offline-first:
  /// 1. 💾 Cargar desde caché local (instantáneo)
  /// 2. 🔄 Lanzar actualización en segundo plano
  /// 3. 📊 Si no hay caché, calcular normalmente
  ///
  /// [userId] - ID del usuario.
  ///
  /// Returns: Resumen con:
  /// - Conteo por tipo de comida
  /// - Top 6 ingredientes
  /// - Top 5 recetas (de todo el historial)
  /// - Calorías totales y promedio
  /// - Macros estimadas (proteínas, carbos, grasas)
  /// - Coste estimado (de la lista de compras actual)
  ///
  /// Si no hay menús, devuelve resumen con valores en 0.
  @override
  Future<StatisticsSummary> getStatisticsSummary(String userId) async {
    //  Intentar cargar del caché local instantáneo
    final cached = await _localDS.getLatest();
    if (cached != null) {
      // Lanzar actualización en segundo plano
      unawaited(refreshStatistics(userId));
      return cached.toSummary();
    }

    //  Si no hay caché, calcular normalmente
    final summary = await _calculateStatisticsSummary(userId);
    return summary ??
        const StatisticsSummary(
          mealTypeCounts: {
            MealType.breakfast: 0,
            MealType.lunch: 0,
            MealType.snack: 0,
            MealType.dinner: 0,
          },
          topIngredients: [],
          topRecipes: [],
          totalWeeklyCalories: 0,
          avgDailyCalories: 0,
          uniqueRecipesCount: 0,
          totalIngredientsCount: 0,
          estimatedCost: 0,
        );
  }

  /// Calcula las estadísticas completas desde los menús.
  ///
  /// [userId] - ID del usuario.
  ///
  /// Returns:
  /// - Estadísticas calculadas si hay menús
  /// - null si el usuario aún no tiene menús
  ///
  /// Cálculos:
  /// 1. Conteo de tipos de comida (del menú actual)
  /// 2. Top ingredientes (normalizados, del menú actual)
  /// 3. Top recetas (de TODOS los menús históricos)
  /// 4. Calorías (del menú actual)
  /// 5. Macros estimadas (usando heurísticas + API)
  /// 6. Coste (de la lista de compras actual)
  ///
  /// Nota: Guarda automáticamente el resultado en caché local.
  Future<StatisticsSummary?> _calculateStatisticsSummary(String userId) async {
    WeeklyMenu? menu;
    final allMenus = await _weeklyMenuRepository.getWeeklyMenus(userId);
    if (allMenus.isNotEmpty) {
      allMenus.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
      menu = allMenus.first;
    }

    // Sin menús todavía
    if (menu == null) {
      return null;
    }

    // Conteo por tipo de comida
    final Map<MealType, int> mealTypeCounts = {
      MealType.breakfast: 0,
      MealType.lunch: 0,
      MealType.snack: 0,
      MealType.dinner: 0,
    };
    for (final day in menu.days) {
      for (final r in day.recipes) {
        mealTypeCounts[r.mealType] = (mealTypeCounts[r.mealType] ?? 0) + 1;
      }
    }

    // Top ingredientes (normalizados) de la semana
    final Map<String, int> ingredientCounts = {};
    for (final day in menu.days) {
      for (final r in day.recipes) {
        for (final ing in r.ingredients) {
          final normalized = _normalizer.normalize(_extractName(ing));
          if (normalized.isEmpty) continue;
          ingredientCounts[normalized] =
              (ingredientCounts[normalized] ?? 0) + 1;
        }
      }
    }
    final topIngredients = ingredientCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = topIngredients
        .take(6)
        .map((e) => IngredientCount(e.key, e.value))
        .toList();

    // Recetas más repetidas (por nombre) - DESDE TODOS LOS MENÚS HISTÓRICOS
    final Map<String, int> recipeCounts = {};
    for (final weeklyMenu in allMenus) {
      for (final day in weeklyMenu.days) {
        for (final r in day.recipes) {
          final name = r.name.value;
          recipeCounts[name] = (recipeCounts[name] ?? 0) + 1;
        }
      }
    }
    final topRecipesList = recipeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topRecipes = topRecipesList
        .take(5)
        .map((e) => RecipeFrequency(e.key, e.value))
        .toList();

    final uniqueRecipes = recipeCounts.length;
    final uniqueIngredients = ingredientCounts.length;

    final total = menu.totalWeeklyCalories;
    final avg = menu.avgDailyCalories;

    // Calcular macros estimadas basadas en ingredientes
    final macros = await _calculateEstimatedMacros(menu);

    // Usar el precio de la última lista de la compra generada
    final estimatedCost = await _shoppingRepository.getTotalPrice();

    final summary = StatisticsSummary(
      mealTypeCounts: mealTypeCounts,
      topIngredients: top,
      topRecipes: topRecipes,
      totalWeeklyCalories: total,
      avgDailyCalories: avg,
      uniqueRecipesCount: uniqueRecipes,
      totalIngredientsCount: uniqueIngredients,
      estimatedCost: estimatedCost,
      totalProteinG: macros['protein']!,
      totalCarbsG: macros['carbs']!,
      totalFatG: macros['fat']!,
    );

    // Guardar en caché local de forma asincrónica
    unawaited(
      _localDS.saveLatest(
        StatisticsCacheModel.fromSummary(summary, menu.weekStartDate),
      ),
    );

    return summary;
  }

  // ===== HELPER METHODS PARA CACHÉ =====

  /// Guarda estadísticas en el caché remoto (Firestore).
  ///
  /// [userId] - ID del usuario.
  /// [summary] - Resumen de estadísticas a cachear.
  /// [menuDate] - Fecha del menú asociado (para validar frescura).
  ///
  /// Nota: Los errores se silencian, el caché no debe impedir la operación principal.
  @override
  Future<void> cacheStatisticsSummary(
    String userId,
    StatisticsSummary summary,
    DateTime menuDate,
  ) async {
    try {
      final cache = StatisticsCacheModel.fromSummary(summary, menuDate);
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionStatistics)
          .doc('summary')
          .set(cache.toJson());
    } catch (e) {
      // Silenciar errores de caché, no debe impedir la carga
    }
  }

  /// Limpia el caché de estadísticas (local y remoto).
  ///
  /// [userId] - ID del usuario.
  ///
  /// Llamado cuando cambia un menú o la lista de compras para
  /// forzar recalculación de estadísticas.
  @override
  Future<void> clearStatisticsCache(String userId) async {
    // Limpiar caché local
    await _localDS.clear();

    // Limpiar Firestore remoto
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionStatistics)
          .doc('summary')
          .delete();
    } catch (_) {}
  }

  // ===== HELPER METHODS PARA ESTADÍSTICAS =====

  /// Extrae el nombre del ingrediente desde un string crudo.
  ///
  /// Heurística: Si el segundo token es una unidad conocida (g, kg, ml, etc.),
  /// el nombre es todo lo que viene después. Si no, asume que la cantidad
  /// es el primer token y el resto es el nombre.
  ///
  /// Ejemplos:
  /// - "200 g pollo" → "pollo"
  /// - "2 ud huevo" → "huevo"
  /// - "pollo pechuga" → "pollo pechuga"
  String _extractName(String raw) {
    final parts = raw.toLowerCase().trim().split(RegExp(r'\s+'));
    if (parts.length <= 2) return raw;
    // Heurística: cantidad + unidad + nombre...
    final maybeUnit = parts[1];
    final knownUnits = {'g', 'gr', 'kg', 'ml', 'l', 'ud', 'uds'};
    if (knownUnits.contains(maybeUnit)) {
      return parts.sublist(2).join(' ');
    }
    return parts.sublist(1).join(' ');
  }

  /// Calcula los macronutrientes estimados para todo el menú semanal.
  ///
  /// [menu] - Menú semanal a analizar.
  ///
  /// Returns: Mapa con totales semanales:
  /// - 'protein': gramos totales de proteína
  /// - 'carbs': gramos totales de carbohidratos
  /// - 'fat': gramos totales de grasas
  ///
  /// Proceso para cada ingrediente:
  /// 1. Parsear cantidad y unidad
  /// 2. Normalizar nombre
  /// 3. Determinar categoría
  /// 4. Obtener perfil de macros (heurística/API)
  /// 5. Escalar según cantidad
  /// 6. Acumular
  Future<Map<String, double>> _calculateEstimatedMacros(WeeklyMenu menu) async {
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final day in menu.days) {
      for (final r in day.recipes) {
        for (final ingRaw in r.ingredients) {
          final portion = _parser.parse(ingRaw);
          final normalized = _normalizer.normalize(portion.name);
          if (normalized.isEmpty) continue;

          final category = _categoryHelper.guessCategory(normalized);
          final macros = await _macrosForPortion(normalized, category, portion);

          totalProtein += macros.protein;
          totalCarbs += macros.carbs;
          totalFat += macros.fat;
        }
      }
    }

    return {
      'protein': double.parse(totalProtein.toStringAsFixed(1)),
      'carbs': double.parse(totalCarbs.toStringAsFixed(1)),
      'fat': double.parse(totalFat.toStringAsFixed(1)),
    };
  }

  /// Calcula macros para una porción específica de un ingrediente.
  ///
  /// [normalized] - Nombre normalizado del ingrediente.
  /// [category] - Categoría del ingrediente.
  /// [portion] - Porción parseada (cantidad + unidad).
  ///
  /// Returns: Perfil de macros escalado a la cantidad especificada.
  ///
  /// Lógica:
  /// - Si es unidad y existe perfil por unidad (ej: huevo) → usar ese perfil × cantidad
  /// - Si es unidad sin perfil → asumir 80g/unidad y usar perfil per 100g
  /// - Si es peso/volumen → convertir a factor (cantidad / 100) y escalar
  Future<_MacroProfile> _macrosForPortion(
    String normalized,
    ShoppingItemCategory category,
    IngredientPortion portion,
  ) async {
    final perUnit = _macroPerUnit[normalized];
    if (portion.unitKind == UnitKind.unit && perUnit != null) {
      // quantityBase = número de unidades
      return perUnit.scale(portion.quantityBase);
    }

    final per100g = await _macroProfilePer100g(normalized, category);

    if (portion.unitKind == UnitKind.unit) {
      // Fallback: estimar 80 g por unidad si no hay perfil unitario
      final grams = portion.quantityBase * 80.0;
      final factor = grams / 100.0;
      return per100g.scale(factor);
    }

    // Peso/volumen: quantityBase ya viene en gramos/ml base
    final factor = portion.quantityBase / 100.0;
    return per100g.scale(factor);
  }

  /// Obtiene el perfil de macros por 100g de un ingrediente.
  ///
  /// [normalized] - Nombre normalizado del ingrediente.
  /// [category] - Categoría del ingrediente (para fallback).
  ///
  /// Returns: Perfil de macros por 100g.
  ///
  /// Estrategia (en orden):
  /// 1. Caché en memoria (API USDA previamente consultada)
  /// 2. API USDA (Cloudflare Worker)
  /// 3. Heurística local (_macroPer100g)
  /// 4. Fallback por categoría
  Future<_MacroProfile> _macroProfilePer100g(
    String normalized,
    ShoppingItemCategory category,
  ) async {
    // 1) Cache local en memoria (API)
    final apiCached = _macroApiCache[normalized];
    if (apiCached != null) return apiCached;

    // 2) API USDA si hay key
    final apiProfile = await _fetchUsdaMacroProfile(normalized);
    if (apiProfile != null) {
      _macroApiCache[normalized] = apiProfile;
      return apiProfile;
    }

    // 3) Heurística local
    return _macroPer100g[normalized] ??
        _categoryMacroPer100g[category] ??
        _categoryMacroPer100g[ShoppingItemCategory.otros]!;
  }

  /// Consulta la API USDA (Cloudflare Worker) para obtener macros.
  ///
  /// [normalized] - Nombre normalizado del ingrediente.
  ///
  /// Returns:
  /// - Perfil de macros si la API tiene datos
  /// - null si falla o no encuentra datos
  ///
  /// URL del Worker: https://groq-worker.smartmealgroq.workers.dev/macros?query=pollo
  ///
  /// Nota: Los errores se silencian, devolviendo null para usar fallback.
  Future<_MacroProfile?> _fetchUsdaMacroProfile(String normalized) async {
    try {
      final uri = Uri.parse(
        _macroWorkerUrl,
      ).replace(queryParameters: {'query': normalized});

      final resp = await http.get(uri, headers: {'Accept': 'application/json'});
      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final protein = (data['protein'] as num?)?.toDouble() ?? 0;
      final carbs = (data['carbs'] as num?)?.toDouble() ?? 0;
      final fat = (data['fat'] as num?)?.toDouble() ?? 0;

      if (protein == 0 && carbs == 0 && fat == 0) return null;

      return _MacroProfile(protein, carbs, fat);
    } catch (_) {
      return null;
    }
  }
}

/// Perfil de macronutrientes para un ingrediente.
///
/// Representa las cantidades de macronutrientes por 100g (o por unidad).
/// - [protein]: gramos de proteína
/// - [carbs]: gramos de carbohidratos
/// - [fat]: gramos de grasas
///
/// Incluye método [scale] para ajustar cantidades según porción.
class _MacroProfile {
  final double protein;
  final double carbs;
  final double fat;

  const _MacroProfile(this.protein, this.carbs, this.fat);

  _MacroProfile scale(double factor) {
    return _MacroProfile(protein * factor, carbs * factor, fat * factor);
  }
}
