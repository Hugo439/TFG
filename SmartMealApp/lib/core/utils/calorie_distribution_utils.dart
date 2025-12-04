class CalorieRange {
  final int min;
  final int max;

  const CalorieRange(this.min, this.max);

  @override
  String toString() => '$min-$max';
}

class MealCalorieDistribution {
  final CalorieRange breakfast;
  final CalorieRange lunch;
  final CalorieRange snack;
  final CalorieRange dinner;

  const MealCalorieDistribution({
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.dinner,
  });

  /// Calcula distribución de calorías por tipo de comida según objetivo diario
  /// 
  /// Distribución típica nutricional:
  /// - Breakfast: 25-30% de calorías diarias
  /// - Lunch: 35-40% de calorías diarias
  /// - Snack: 10-15% de calorías diarias
  /// - Dinner: 25-30% de calorías diarias
  factory MealCalorieDistribution.fromDailyTarget(int dailyCalories) {
    // Breakfast: 27.5% promedio con variación ±10%
    final breakfastBase = (dailyCalories * 0.275).round();
    final breakfastMin = (breakfastBase * 0.90).round();
    final breakfastMax = (breakfastBase * 1.10).round();

    // Lunch: 37.5% promedio con variación ±10%
    final lunchBase = (dailyCalories * 0.375).round();
    final lunchMin = (lunchBase * 0.90).round();
    final lunchMax = (lunchBase * 1.10).round();

    // Snack: 12.5% promedio con variación ±15%
    final snackBase = (dailyCalories * 0.125).round();
    final snackMin = (snackBase * 0.85).round();
    final snackMax = (snackBase * 1.15).round();

    // Dinner: 27.5% promedio con variación ±10%
    final dinnerBase = (dailyCalories * 0.275).round();
    final dinnerMin = (dinnerBase * 0.90).round();
    final dinnerMax = (dinnerBase * 1.10).round();

    return MealCalorieDistribution(
      breakfast: CalorieRange(breakfastMin, breakfastMax),
      lunch: CalorieRange(lunchMin, lunchMax),
      snack: CalorieRange(snackMin, snackMax),
      dinner: CalorieRange(dinnerMin, dinnerMax),
    );
  }
}