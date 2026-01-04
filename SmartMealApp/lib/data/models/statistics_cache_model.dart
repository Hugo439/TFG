import 'package:smartmeal/domain/value_objects/statistics_models.dart';
import 'package:smartmeal/domain/entities/recipe.dart';

/// Modelo de datos para caché de estadísticas del menú.
///
/// Responsabilidad:
/// - Cachear estadísticas calculadas del menú semanal en Firestore
/// - Evitar recalcular estadísticas cada vez que se abre la pantalla
///
/// Casos de uso:
/// 1. Usuario genera menú → se calculan estadísticas → se cachean
/// 2. Usuario abre pantalla estadísticas → se cargan desde caché
/// 3. Usuario modifica menú → caché invalida (menuDate cambia)
///
/// Campos:
/// - **mealTypeCounts**: contador de comidas por tipo (Map<string, int>)
/// - **topIngredients**: top 10 ingredientes más usados
/// - **topRecipes**: top 10 recetas más frecuentes
/// - **totalWeeklyCalories**: calorías totales de la semana
/// - **avgDailyCalories**: promedio diario de calorías
/// - **uniqueRecipesCount**: número de recetas únicas
/// - **totalIngredientsCount**: número total de ingredientes
/// - **estimatedCost**: coste estimado del menú
/// - **totalProteinG**: gramos totales de proteína
/// - **totalCarbsG**: gramos totales de carbohidratos
/// - **totalFatG**: gramos totales de grasa
/// - **menuDate**: fecha del menú (para detectar cambios)
/// - **cachedAt**: timestamp de cacheado
///
/// Ruta Firestore:
/// ```
/// users/{userId}/statistics_cache/{menuId}
/// ```
///
/// Ejemplo:
/// ```json
/// {
///   "mealTypeCounts": {"breakfast": 7, "lunch": 7, "snack": 7, "dinner": 7},
///   "topIngredients": [{"name": "Pollo", "count": 5}, ...],
///   "topRecipes": [{"name": "Pollo al horno", "count": 2}, ...],
///   "totalWeeklyCalories": 14000,
///   "avgDailyCalories": 2000.0,
///   "uniqueRecipesCount": 20,
///   "totalIngredientsCount": 45,
///   "estimatedCost": 45.50,
///   "totalProteinG": 350.0,
///   "totalCarbsG": 1200.0,
///   "totalFatG": 450.0,
///   "menuDate": "2024-01-01T00:00:00.000Z",
///   "cachedAt": "2024-01-01T10:30:00.000Z"
/// }
/// ```
///
/// Validación de caché:
/// - Si menuDate != weeklyMenu.weekStartDate → recalcular
/// - Si cachedAt > 7 días → recalcular
class StatisticsCacheModel {
  final Map<String, int> mealTypeCounts; // string representation
  final List<Map<String, dynamic>> topIngredients;
  final List<Map<String, dynamic>> topRecipes;
  final int totalWeeklyCalories;
  final double avgDailyCalories;
  final int uniqueRecipesCount;
  final int totalIngredientsCount;
  final double estimatedCost;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final DateTime menuDate; // Fecha del menú para detectar cambios
  final DateTime cachedAt; // Cuándo se cachéó

  const StatisticsCacheModel({
    required this.mealTypeCounts,
    required this.topIngredients,
    required this.topRecipes,
    required this.totalWeeklyCalories,
    required this.avgDailyCalories,
    required this.uniqueRecipesCount,
    required this.totalIngredientsCount,
    required this.estimatedCost,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.menuDate,
    required this.cachedAt,
  });

  /// Crea modelo desde StatisticsSummary del dominio.
  ///
  /// Convierte:
  /// - MealType enum → string ("breakfast", "lunch", etc.)
  /// - IngredientCount/RecipeFrequency → Map<String, dynamic>
  ///
  /// Usado al cachear estadísticas recién calculadas.
  factory StatisticsCacheModel.fromSummary(
    StatisticsSummary summary,
    DateTime menuDate,
  ) {
    return StatisticsCacheModel(
      mealTypeCounts: summary.mealTypeCounts.map(
        (k, v) => MapEntry(_mealTypeToString(k), v),
      ),
      topIngredients: summary.topIngredients
          .map((e) => {'name': e.name, 'count': e.count})
          .toList(),
      topRecipes: summary.topRecipes
          .map((e) => {'name': e.name, 'count': e.count})
          .toList(),
      totalWeeklyCalories: summary.totalWeeklyCalories,
      avgDailyCalories: summary.avgDailyCalories,
      uniqueRecipesCount: summary.uniqueRecipesCount,
      totalIngredientsCount: summary.totalIngredientsCount,
      estimatedCost: summary.estimatedCost,
      totalProteinG: summary.totalProteinG,
      totalCarbsG: summary.totalCarbsG,
      totalFatG: summary.totalFatG,
      menuDate: menuDate,
      cachedAt: DateTime.now(),
    );
  }

  /// Parsea modelo desde Map de Firestore.
  ///
  /// Reconstruye tipos complejos:
  /// - Map<String, int> para mealTypeCounts
  /// - List<Map> para topIngredients/topRecipes
  /// - DateTime desde strings ISO 8601
  ///
  /// Usado al cargar caché desde Firestore.
  factory StatisticsCacheModel.fromJson(Map<String, dynamic> json) {
    // Reconstruir mealTypeCounts desde string keys
    final mealMap = <String, int>{};
    final mealCountsJson = json['mealTypeCounts'] as Map<String, dynamic>?;
    if (mealCountsJson != null) {
      mealCountsJson.forEach((key, value) {
        mealMap[key] = value as int;
      });
    }

    return StatisticsCacheModel(
      mealTypeCounts: mealMap,
      topIngredients: List<Map<String, dynamic>>.from(
        (json['topIngredients'] as List?) ?? [],
      ),
      topRecipes: List<Map<String, dynamic>>.from(
        (json['topRecipes'] as List?) ?? [],
      ),
      totalWeeklyCalories: json['totalWeeklyCalories'] as int? ?? 0,
      avgDailyCalories: (json['avgDailyCalories'] as num?)?.toDouble() ?? 0,
      uniqueRecipesCount: json['uniqueRecipesCount'] as int? ?? 0,
      totalIngredientsCount: json['totalIngredientsCount'] as int? ?? 0,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
      totalProteinG: (json['totalProteinG'] as num?)?.toDouble() ?? 0,
      totalCarbsG: (json['totalCarbsG'] as num?)?.toDouble() ?? 0,
      totalFatG: (json['totalFatG'] as num?)?.toDouble() ?? 0,
      menuDate: DateTime.parse(
        json['menuDate'] as String? ?? DateTime.now().toIso8601String(),
      ),
      cachedAt: DateTime.parse(
        json['cachedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convierte a Map para persistencia en Firestore.
  ///
  /// Convierte DateTime → ISO 8601 strings.
  Map<String, dynamic> toJson() => {
    'mealTypeCounts': mealTypeCounts,
    'topIngredients': topIngredients,
    'topRecipes': topRecipes,
    'totalWeeklyCalories': totalWeeklyCalories,
    'avgDailyCalories': avgDailyCalories,
    'uniqueRecipesCount': uniqueRecipesCount,
    'totalIngredientsCount': totalIngredientsCount,
    'estimatedCost': estimatedCost,
    'totalProteinG': totalProteinG,
    'totalCarbsG': totalCarbsG,
    'totalFatG': totalFatG,
    'menuDate': menuDate.toIso8601String(),
    'cachedAt': cachedAt.toIso8601String(),
  };

  /// Convierte modelo cacheado a StatisticsSummary del dominio.
  ///
  /// Reconstruye:
  /// - string → MealType enum
  /// - Map<String, dynamic> → IngredientCount/RecipeFrequency
  ///
  /// Usado al mostrar estadísticas desde caché.
  StatisticsSummary toSummary() {
    // Reconstruir MealType enum desde strings
    final mealMap = <MealType, int>{};
    mealTypeCounts.forEach((key, value) {
      final mealType = _stringToMealType(key);
      mealMap[mealType] = value;
    });

    return StatisticsSummary(
      mealTypeCounts: mealMap,
      topIngredients: topIngredients
          .map((e) => IngredientCount(e['name'] as String, e['count'] as int))
          .toList(),
      topRecipes: topRecipes
          .map((e) => RecipeFrequency(e['name'] as String, e['count'] as int))
          .toList(),
      totalWeeklyCalories: totalWeeklyCalories,
      avgDailyCalories: avgDailyCalories,
      uniqueRecipesCount: uniqueRecipesCount,
      totalIngredientsCount: totalIngredientsCount,
      estimatedCost: estimatedCost,
      totalProteinG: totalProteinG,
      totalCarbsG: totalCarbsG,
      totalFatG: totalFatG,
    );
  }

  /// Convierte MealType enum a string para Firestore.
  static String _mealTypeToString(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.snack:
        return 'snack';
      case MealType.dinner:
        return 'dinner';
    }
  }

  /// Convierte string de Firestore a MealType enum.
  ///
  /// Default: MealType.breakfast si string no reconocido.
  static MealType _stringToMealType(String type) {
    switch (type) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'snack':
        return MealType.snack;
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.breakfast;
    }
  }
}
