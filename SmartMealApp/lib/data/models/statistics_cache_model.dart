import 'package:smartmeal/domain/value_objects/statistics_models.dart';
import 'package:smartmeal/domain/entities/recipe.dart';

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

  // Convertir de StatisticsSummary a cache model
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

  // Convertir de JSON (desde Firestore)
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

  // Convertir a JSON (para Firestore)
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

  // Convertir de cache model a StatisticsSummary (para mostrarlo)
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

  // Helper methods para convertir MealType
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
