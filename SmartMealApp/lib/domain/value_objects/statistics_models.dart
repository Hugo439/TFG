import 'package:smartmeal/domain/entities/recipe.dart';

class IngredientCount {
  final String name;
  final int count;
  const IngredientCount(this.name, this.count);
}

class RecipeFrequency {
  final String name;
  final int count;
  const RecipeFrequency(this.name, this.count);
}

class StatisticsSummary {
  final Map<MealType, int> mealTypeCounts; // cantidad de recetas por tipo
  final List<IngredientCount> topIngredients; // top ingredientes de la semana
  final List<RecipeFrequency> topRecipes; // recetas más repetidas
  final int totalWeeklyCalories;
  final double avgDailyCalories;
  final int uniqueRecipesCount; // variedad
  final int totalIngredientsCount; // total ingredientes únicos
  final double estimatedCost; // costo aproximado semanal en €
  final double totalProteinG; // proteínas totales semana (g)
  final double totalCarbsG; // carbohidratos totales semana (g)
  final double totalFatG; // grasas totales semana (g)

  const StatisticsSummary({
    required this.mealTypeCounts,
    required this.topIngredients,
    required this.topRecipes,
    required this.totalWeeklyCalories,
    required this.avgDailyCalories,
    required this.uniqueRecipesCount,
    required this.totalIngredientsCount,
    required this.estimatedCost,
    this.totalProteinG = 0,
    this.totalCarbsG = 0,
    this.totalFatG = 0,
  });

  // Getters para macros diarios promedio
  double get avgDailyProteinG => totalProteinG / 7;
  double get avgDailyCarbsG => totalCarbsG / 7;
  double get avgDailyFatG => totalFatG / 7;
}
