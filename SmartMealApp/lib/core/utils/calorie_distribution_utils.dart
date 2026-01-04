/// Representa un rango de calorías con mínimo y máximo.
///
/// Usado para especificar rangos flexibles de calorías permitidas
/// en cada comida del día.
class CalorieRange {
  /// Cantidad mínima de calorías del rango.
  final int min;

  /// Cantidad máxima de calorías del rango.
  final int max;

  const CalorieRange(this.min, this.max);

  @override
  String toString() => '$min-$max';
}

/// Distribución de calorías por tipo de comida en un día.
///
/// Define rangos calóricos específicos para cada comida del día,
/// basados en recomendaciones nutricionales estándar.
class MealCalorieDistribution {
  /// Rango de calorías para el desayuno.
  final CalorieRange breakfast;

  /// Rango de calorías para la comida (almuerzo).
  final CalorieRange lunch;

  /// Rango de calorías para el snack (merienda).
  final CalorieRange snack;

  /// Rango de calorías para la cena.
  final CalorieRange dinner;

  const MealCalorieDistribution({
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.dinner,
  });

  /// Crea una distribución calórica basada en el objetivo diario total.
  ///
  /// Aplica porcentajes nutricionales recomendados para cada comida,
  /// con márgenes de flexibilidad para variar las recetas:
  ///
  /// **Distribución estándar:**
  /// - **Desayuno**: 25-30% (promedio 27.5% con variación ±10%)
  /// - **Comida**: 35-40% (promedio 37.5% con variación ±10%)
  /// - **Snack**: 10-15% (promedio 12.5% con variación ±15%)
  /// - **Cena**: 25-30% (promedio 27.5% con variación ±10%)
  ///
  /// La variación permite flexibilidad para que el generador de menús
  /// pueda adaptar las recetas sin ser excesivamente estricto.
  ///
  /// **Parámetro:**
  /// - [dailyCalories]: Objetivo calórico diario total del usuario
  ///
  /// **Retorna:** [MealCalorieDistribution] con rangos para cada comida
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final distribution = MealCalorieDistribution.fromDailyTarget(2000);
  /// print(distribution.breakfast); // 495-605 kcal
  /// print(distribution.lunch);     // 675-825 kcal
  /// print(distribution.snack);     // 212-287 kcal
  /// print(distribution.dinner);    // 495-605 kcal
  /// // Total: ~1877-2322 kcal (centrado en 2000)
  /// ```
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
