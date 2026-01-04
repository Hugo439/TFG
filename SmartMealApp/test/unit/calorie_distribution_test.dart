// =============================================================================
// PRUEBAS UNITARIAS - DISTRIBUCIÓN DE CALORÍAS POR COMIDA
// =============================================================================
// Verifica que las calorías diarias se distribuyan correctamente entre comidas
// Desayuno: 27.5% ±10%, Comida: 37.5% ±10%, Merienda: 12.5% ±15%, Cena: 27.5% ±10%

import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/core/utils/calorie_distribution_utils.dart';

void main() {
  group('CalorieDistribution - Distribución por comida', () {
    test('Distribución para 2000 kcal/día', () {
      // Given: Objetivo diario de 2000 kcal
      const dailyTarget = 2000;

      // When: Calculamos distribución por comida
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // Then: Verificamos rangos para cada comida
      // Desayuno: 27.5% de 2000 = 550 kcal, ±10% → [495, 605]
      expect(distribution.breakfast.min, equals(495));
      expect(distribution.breakfast.max, equals(605));

      // Comida: 37.5% de 2000 = 750 kcal, ±10% → [675, 825]
      expect(distribution.lunch.min, equals(675));
      expect(distribution.lunch.max, equals(825));

      // Merienda: 12.5% de 2000 = 250 kcal, ±15% → [212, 287]
      expect(distribution.snack.min, equals(213));
      expect(distribution.snack.max, equals(288));

      // Cena: 27.5% de 2000 = 550 kcal, ±10% → [495, 605]
      expect(distribution.dinner.min, equals(495));
      expect(distribution.dinner.max, equals(605));
    });

    test('Distribución para 1500 kcal/día (déficit calórico)', () {
      // Given: Objetivo diario de 1500 kcal (persona queriendo perder peso)
      const dailyTarget = 1500;

      // When: Calculamos distribución
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // Then: Verificamos proporciones correctas
      // Desayuno: 27.5% de 1500 = 412.5, ±10% → [371, 453]
      expect(distribution.breakfast.min, equals(372));
      expect(distribution.breakfast.max, equals(454));

      // Comida: 37.5% de 1500 = 562.5, ±10% → [506, 618]
      expect(distribution.lunch.min, equals(506));
      expect(distribution.lunch.max, equals(618));

      // Merienda: 12.5% de 1500 = 187.5, ±15% → [159, 215]
      expect(distribution.snack.min, equals(159));
      expect(distribution.snack.max, equals(215));

      // Cena: 27.5% de 1500 = 412.5, ±10% → [371, 453]
      expect(distribution.dinner.min, equals(371));
      expect(distribution.dinner.max, equals(453));
    });

    test('Distribución para 3000 kcal/día (superávit calórico)', () {
      // Given: Objetivo diario de 3000 kcal (persona ganando músculo)
      const dailyTarget = 3000;

      // When: Calculamos distribución
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // Then: Verificamos rangos más altos
      // Desayuno: 27.5% de 3000 = 825, ±10% → [742, 907]
      expect(distribution.breakfast.min, equals(743));
      expect(distribution.breakfast.max, equals(908));

      // Comida: 37.5% de 3000 = 1125, ±10% → [1012, 1237]
      expect(distribution.lunch.min, equals(1012));
      expect(distribution.lunch.max, equals(1237));

      // Merienda: 12.5% de 3000 = 375, ±15% → [318, 431]
      expect(distribution.snack.min, equals(318));
      expect(distribution.snack.max, equals(431));

      // Cena: 27.5% de 3000 = 825, ±10% → [742, 907]
      expect(distribution.dinner.min, equals(742));
      expect(distribution.dinner.max, equals(907));
    });

    test('Suma de rangos máximos no excede significativamente el objetivo', () {
      // Given: Objetivo de 2500 kcal
      const dailyTarget = 2500;

      // When: Calculamos distribución
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // Then: Suma de máximos debe ser razonable (no más de ~117% del objetivo)
      final sumMax =
          distribution.breakfast.max +
          distribution.lunch.max +
          distribution.snack.max +
          distribution.dinner.max;

      expect(sumMax, lessThanOrEqualTo(dailyTarget * 1.17));
    });

    test('Suma de rangos mínimos no es demasiado baja', () {
      // Given: Objetivo de 2200 kcal
      const dailyTarget = 2200;

      // When: Calculamos distribución
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // Then: Suma de mínimos debe ser razonable (al menos ~85% del objetivo)
      final sumMin =
          distribution.breakfast.min +
          distribution.lunch.min +
          distribution.snack.min +
          distribution.dinner.min;

      expect(sumMin, greaterThanOrEqualTo(dailyTarget * 0.85));
    });

    test('Comida siempre tiene el mayor rango calórico', () {
      // Given: Cualquier objetivo
      const dailyTarget = 2100;

      // When: Calculamos distribución
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // Then: Comida debe tener más calorías que cualquier otra comida
      expect(distribution.lunch.min, greaterThan(distribution.breakfast.min));
      expect(distribution.lunch.min, greaterThan(distribution.snack.min));
      expect(distribution.lunch.min, greaterThan(distribution.dinner.min));
    });

    test('Merienda siempre tiene el menor rango calórico', () {
      // Given: Cualquier objetivo
      const dailyTarget = 1800;

      // When: Calculamos distribución
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // Then: Merienda debe tener menos calorías que cualquier otra comida
      expect(distribution.snack.max, lessThan(distribution.breakfast.max));
      expect(distribution.snack.max, lessThan(distribution.lunch.max));
      expect(distribution.snack.max, lessThan(distribution.dinner.max));
    });

    test(
      'Flexibilidad de la merienda (±15%) es mayor que otras comidas (±10%)',
      () {
        // Given: Objetivo de 2000 kcal
        const dailyTarget = 2000;

        // When: Calculamos distribución
        final distribution = MealCalorieDistribution.fromDailyTarget(
          dailyTarget,
        );

        // Then: Rango relativo de merienda debe ser mayor
        final breakfastFlexibility =
            (distribution.breakfast.max - distribution.breakfast.min) /
            distribution.breakfast.min;
        final snackFlexibility =
            (distribution.snack.max - distribution.snack.min) /
            distribution.snack.min;

        expect(snackFlexibility, greaterThan(breakfastFlexibility));
      },
    );
  });

  group('CalorieRange - Validaciones', () {
    test('CalorieRange se crea correctamente', () {
      // Given/When: Creamos un rango de calorías
      const range = CalorieRange(400, 600);

      // Then: Valores se asignan correctamente
      expect(range.min, equals(400));
      expect(range.max, equals(600));
    });

    test('Rango permite cierta flexibilidad para generación de menú', () {
      // Given: Distribución para 2000 kcal
      const dailyTarget = 2000;
      final distribution = MealCalorieDistribution.fromDailyTarget(dailyTarget);

      // When: Verificamos amplitud de cada rango
      final breakfastRange =
          distribution.breakfast.max - distribution.breakfast.min;
      final lunchRange = distribution.lunch.max - distribution.lunch.min;
      final snackRange = distribution.snack.max - distribution.snack.min;
      final dinnerRange = distribution.dinner.max - distribution.dinner.min;

      // Then: Cada rango debe tener al menos 50 kcal de flexibilidad
      expect(breakfastRange, greaterThanOrEqualTo(50));
      expect(lunchRange, greaterThanOrEqualTo(50));
      expect(snackRange, greaterThanOrEqualTo(50));
      expect(dinnerRange, greaterThanOrEqualTo(50));
    });
  });
}
