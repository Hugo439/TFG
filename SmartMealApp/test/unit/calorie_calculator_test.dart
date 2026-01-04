// =============================================================================
// PRUEBAS UNITARIAS - CÁLCULO DE CALORÍAS
// =============================================================================
// Prueba el cálculo de necesidades calóricas usando Mifflin-St Jeor
// Casos: diferentes perfiles (hombre/mujer), objetivos, actividad y edges

import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/core/utils/calorie_calculator_utils.dart';

void main() {
  group('CalorieCalculator - BMR (Metabolismo Basal)', () {
    test('BMR - Hombre adulto promedio', () {
      // Given: Hombre de 25 años, 70kg, 175cm
      const weightKg = 70.0;
      const heightCm = 175;
      const age = 25;
      const gender = 'hombre';

      // When: Calculamos BMR
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
      );

      // Then: BMR esperado según Mifflin-St Jeor
      // BMR = (10 × 70) + (6.25 × 175) - (5 × 25) + 5
      // BMR = 700 + 1093.75 - 125 + 5 = 1673.75
      expect(bmr, closeTo(1673.75, 0.1));
    });

    test('BMR - Mujer adulta promedio', () {
      // Given: Mujer de 28 años, 60kg, 165cm
      const weightKg = 60.0;
      const heightCm = 165;
      const age = 28;
      const gender = 'mujer';

      // When: Calculamos BMR
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
      );

      // Then: BMR esperado
      // BMR = (10 × 60) + (6.25 × 165) - (5 × 28) - 161
      // BMR = 600 + 1031.25 - 140 - 161 = 1330.25
      expect(bmr, closeTo(1330.25, 0.1));
    });

    test('BMR - Persona mayor (edge case edad alta)', () {
      // Given: Hombre de 70 años, 75kg, 170cm
      const weightKg = 75.0;
      const heightCm = 170;
      const age = 70;
      const gender = 'male';

      // When: Calculamos BMR
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
      );

      // Then: BMR = (10 × 75) + (6.25 × 170) - (5 × 70) + 5
      // BMR = 750 + 1062.5 - 350 + 5 = 1467.5
      expect(bmr, closeTo(1467.5, 0.1));
    });

    test('BMR - Persona joven (edge case edad baja)', () {
      // Given: Mujer de 18 años, 55kg, 160cm
      const weightKg = 55.0;
      const heightCm = 160;
      const age = 18;
      const gender = 'female';

      // When: Calculamos BMR
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
      );

      // Then: BMR = (10 × 55) + (6.25 × 160) - (5 × 18) - 161
      // BMR = 550 + 1000 - 90 - 161 = 1299
      expect(bmr, closeTo(1299.0, 0.1));
    });

    test('BMR - Sin especificar género (asume hombre por defecto)', () {
      // Given: Datos sin género
      const weightKg = 70.0;
      const heightCm = 175;
      const age = 30;

      // When: Calculamos BMR sin gender
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
      );

      // Then: Debe usar fórmula de hombre (+5)
      // BMR = (10 × 70) + (6.25 × 175) - (5 × 30) + 5
      // BMR = 700 + 1093.75 - 150 + 5 = 1648.75
      expect(bmr, closeTo(1648.75, 0.1));
    });

    test('BMR - Sin especificar edad (usa 30 por defecto)', () {
      // Given: Datos sin edad
      const weightKg = 65.0;
      const heightCm = 170;
      const gender = 'mujer';

      // When: Calculamos BMR sin age
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        gender: gender,
      );

      // Then: Debe usar edad 30 por defecto
      // BMR = (10 × 65) + (6.25 × 170) - (5 × 30) - 161
      // BMR = 650 + 1062.5 - 150 - 161 = 1401.5
      expect(bmr, closeTo(1401.5, 0.1));
    });
  });

  group('CalorieCalculator - TDEE (Gasto Energético Total)', () {
    test('TDEE - Actividad sedentaria', () {
      // Given: BMR de 1500 kcal, actividad sedentaria
      const bmr = 1500.0;
      const activityLevel = 'sedentary';

      // When: Calculamos TDEE
      final tdee = CalorieCalculator.calculateTDEE(
        bmr: bmr,
        activityLevel: activityLevel,
      );

      // Then: TDEE = BMR × 1.2 = 1500 × 1.2 = 1800
      expect(tdee, closeTo(1800.0, 0.1));
    });

    test('TDEE - Actividad ligera', () {
      // Given: BMR de 1600 kcal, actividad ligera
      const bmr = 1600.0;
      const activityLevel = 'light';

      // When: Calculamos TDEE
      final tdee = CalorieCalculator.calculateTDEE(
        bmr: bmr,
        activityLevel: activityLevel,
      );

      // Then: TDEE = BMR × 1.375 = 1600 × 1.375 = 2200
      expect(tdee, closeTo(2200.0, 0.1));
    });

    test('TDEE - Actividad moderada', () {
      // Given: BMR de 1700 kcal, actividad moderada
      const bmr = 1700.0;
      const activityLevel = 'moderate';

      // When: Calculamos TDEE
      final tdee = CalorieCalculator.calculateTDEE(
        bmr: bmr,
        activityLevel: activityLevel,
      );

      // Then: TDEE = BMR × 1.55 = 1700 × 1.55 = 2635
      expect(tdee, closeTo(2635.0, 0.1));
    });

    test('TDEE - Actividad muy activa', () {
      // Given: BMR de 1800 kcal, actividad muy activa
      const bmr = 1800.0;
      const activityLevel = 'very_active';

      // When: Calculamos TDEE
      final tdee = CalorieCalculator.calculateTDEE(
        bmr: bmr,
        activityLevel: activityLevel,
      );

      // Then: TDEE = BMR × 1.9 = 1800 × 1.9 = 3420
      expect(tdee, closeTo(3420.0, 0.1));
    });
  });

  group('CalorieCalculator - Ajuste por objetivo', () {
    test('Objetivo: perder peso (déficit calórico)', () {
      // Given: Perfil con objetivo de perder peso
      const weightKg = 70.0;
      const heightCm = 175;
      const age = 30;
      const goal = 'perder peso';

      // When: Calculamos calorías objetivo
      final targetCalories = CalorieCalculator.calculateDailyCalorieTarget(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        goal: goal,
        activityLevel: 'moderate',
      );

      // Then: Debe aplicar déficit de 500 kcal
      // BMR ≈ 1648, TDEE ≈ 2554, Target ≈ 2054
      expect(targetCalories, greaterThan(1500));
      expect(targetCalories, lessThan(2500));
    });

    test('Objetivo: mantener peso', () {
      // Given: Perfil con objetivo de mantener
      const weightKg = 65.0;
      const heightCm = 168;
      const age = 28;
      const goal = 'mantener peso';

      // When: Calculamos calorías objetivo
      final targetCalories = CalorieCalculator.calculateDailyCalorieTarget(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        goal: goal,
        activityLevel: 'moderate',
      );

      // Then: Debe ser igual al TDEE (sin ajuste)
      expect(targetCalories, greaterThan(1800));
      expect(targetCalories, lessThan(2500));
    });

    test('Objetivo: ganar músculo (superávit calórico)', () {
      // Given: Perfil con objetivo de ganar músculo
      const weightKg = 75.0;
      const heightCm = 180;
      const age = 25;
      const goal = 'ganar músculo';

      // When: Calculamos calorías objetivo
      final targetCalories = CalorieCalculator.calculateDailyCalorieTarget(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        goal: goal,
        activityLevel: 'moderate',
      );

      // Then: Debe aplicar superávit de 400 kcal
      // BMR ≈ 1740, TDEE ≈ 2697, Target ≈ 3097
      expect(targetCalories, greaterThan(2500));
      expect(targetCalories, lessThan(3500));
    });

    test('Flujo completo: BMR → TDEE → Ajuste por objetivo', () {
      // Given: Mujer de 30 años, 65kg, 168cm, actividad moderada, objetivo perder peso
      const weightKg = 65.0;
      const heightCm = 168;
      const age = 30;
      const goal = 'perder peso';

      // When: Calculamos todo el flujo
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: 'mujer',
      );

      final tdee = CalorieCalculator.calculateTDEE(
        bmr: bmr,
        activityLevel: 'moderate',
      );

      final targetCalories = CalorieCalculator.calculateDailyCalorieTarget(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        goal: goal,
        activityLevel: 'moderate',
      );

      // Then: Verificamos que el flujo completo produce un resultado razonable
      expect(bmr, greaterThan(1000));
      expect(tdee, greaterThan(bmr)); // TDEE siempre > BMR
      expect(
        targetCalories,
        lessThan(tdee.round()),
      ); // Déficit para perder peso
      expect(
        targetCalories,
        greaterThan(1200),
      ); // No menos de 1200 kcal (mínimo saludable)
    });
  });
}
