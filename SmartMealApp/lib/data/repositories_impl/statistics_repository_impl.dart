import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/statistics_repository.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_category.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_unit_kind.dart';
import 'package:smartmeal/domain/value_objects/statistics_models.dart';
import 'package:smartmeal/data/models/statistics_cache_model.dart';
import 'package:smartmeal/domain/services/shopping/cost_estimator.dart';
import 'package:smartmeal/data/datasources/local/statistics_local_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final WeeklyMenuRepository _weeklyMenuRepository;
  final ShoppingRepository _shoppingRepository;
  final SmartIngredientNormalizer _normalizer;
  final SmartCategoryHelper _categoryHelper;
  final CostEstimator _costEstimator;
  final IngredientParser _parser;
  final FirebaseFirestore _firestore;
  final StatisticsLocalDatasource _localDS;
  final Map<String, StatisticsCacheModel> _memoryCache = {};
  final Map<String, _MacroProfile> _macroApiCache = {};
  final String _macroWorkerUrl;

  // Macros heurísticos base por 100 g (aprox)
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
  static const Map<String, _MacroProfile> _macroPerUnit = {
    'huevo': _MacroProfile(6.3, 0.4, 5.3),
    'platano': _MacroProfile(1.3, 27, 0.4),
    'manzana': _MacroProfile(0.5, 25, 0.3),
    'naranja': _MacroProfile(1.2, 15, 0.2),
    'tomate': _MacroProfile(1, 5, 0.2),
    'yogur': _MacroProfile(4, 5, 2), // 1 unidad 125g aprox
  };

  // Fallback por categoría (por 100 g)
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
    this._categoryHelper,
    this._costEstimator, {
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

  // Refresca estadísticas en segundo plano y actualiza caché local
  Future<void> refreshStatistics(String userId) async {
    WeeklyMenu? menu;
    final allMenus = await _weeklyMenuRepository.getWeeklyMenus(userId);
    if (allMenus.isNotEmpty) {
      allMenus.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
      menu = allMenus.first;
    }
    if (menu == null) return;
    final summary = await getStatisticsSummary(userId);
    await _localDS.saveLatest(StatisticsCacheModel.fromSummary(summary, menu.weekStartDate));
  }

  @override
  Future<StatisticsSummary> getStatisticsSummary(String userId) async {
    //  Intentar cargar del caché local instantáneo
    final cached = await _localDS.getLatest();
    if (cached != null) {
      // Lanzar actualización en segundo plano
      refreshStatistics(userId);
      return cached.toSummary();
    }

    //  Si no hay caché, calcular normalmente
    WeeklyMenu? menu;
    final allMenus = await _weeklyMenuRepository.getWeeklyMenus(userId);
    if (allMenus.isNotEmpty) {
      allMenus.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
      menu = allMenus.first;
    }

    // Sin menús todavía
    if (menu == null) {
      return const StatisticsSummary(
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

    // Verificar si hay caché válido (mismo menú)
    try {
      final cached = await _getCachedStatistics(userId);
      if (cached != null &&
          _isSameMenuDate(cached.menuDate, menu.weekStartDate)) {
        return cached.toSummary();
      }
    } catch (e) {
      // Si hay error al recuperar caché, continuar con cálculo normal
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

    // Recetas más repetidas (por nombre)
    final Map<String, int> recipeCounts = {};
    for (final day in menu.days) {
      for (final r in day.recipes) {
        final name = r.name.value;
        recipeCounts[name] = (recipeCounts[name] ?? 0) + 1;
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

    // Guardar en caché local y remoto de forma asincrónica
    unawaited(_localDS.saveLatest(StatisticsCacheModel.fromSummary(summary, menu.weekStartDate)));
    _cacheStatistics(userId, summary, menu.weekStartDate);



    return summary;
  }

  // ===== HELPER METHODS PARA CACHÉ =====
  @override
  Future<void> cacheStatisticsSummary(
    String userId,
    StatisticsSummary summary,
    DateTime menuDate,
  ) async {
    try {
      final cache = StatisticsCacheModel.fromSummary(summary, menuDate);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('statistics')
          .doc('summary')
          .set(cache.toJson());
    } catch (e) {
      // Silenciar errores de caché, no debe impedir la carga
    }
  }

  Future<void> _cacheStatistics(
    String userId,
    StatisticsSummary summary,
    DateTime menuDate,
  ) async {
    final cache = StatisticsCacheModel.fromSummary(summary, menuDate);
    _memoryCache[userId] = cache;

    // Ejecutar de forma asincrónica sin esperar
    unawaited(_saveLocalCache(userId, cache));
    unawaited(cacheStatisticsSummary(userId, summary, menuDate));
  }

  Future<StatisticsCacheModel?> _getCachedStatistics(String userId) async {
    // 1) Memoria
    final mem = _memoryCache[userId];
    if (mem != null) return mem;

    // 2) Disco local
    final local = await _loadLocalCache(userId);
    if (local != null) {
      _memoryCache[userId] = local;
      return local;
    }

    // 3) Firestore remoto
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('statistics')
          .doc('summary')
          .get();

      if (doc.exists) {
        final remote = StatisticsCacheModel.fromJson(doc.data() ?? {});
        _memoryCache[userId] = remote;
        unawaited(_saveLocalCache(userId, remote));
        return remote;
      }
    } catch (e) {
      // Ignorar errores de caché
    }

    return null;
  }

  Future<void> _saveLocalCache(
    String userId,
    StatisticsCacheModel cache,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey(userId), jsonEncode(cache.toJson()));
  }

  Future<StatisticsCacheModel?> _loadLocalCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey(userId));
    if (raw == null) return null;
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      return StatisticsCacheModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  String _localKey(String userId) => 'stats_cache_$userId';

  @override
  Future<void> clearStatisticsCache(String userId) async {
    // Limpiar memoria
    _memoryCache.remove(userId);

    // Limpiar SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localKey(userId));
    } catch (_) {}

    // Limpiar Firestore
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('statistics')
          .doc('summary')
          .delete();
    } catch (_) {}
  }

  bool _isSameMenuDate(DateTime cachedDate, DateTime currentDate) {
    // Comparar solo año-mes-día (ignorar hora)
    return cachedDate.year == currentDate.year &&
        cachedDate.month == currentDate.month &&
        cachedDate.day == currentDate.day;
  }

  // ===== HELPER METHODS PARA ESTADÍSTICAS =====
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

class _MacroProfile {
  final double protein;
  final double carbs;
  final double fat;

  const _MacroProfile(this.protein, this.carbs, this.fat);

  _MacroProfile scale(double factor) {
    return _MacroProfile(protein * factor, carbs * factor, fat * factor);
  }
}
