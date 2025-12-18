/// Calcula las necesidades calóricas diarias de un usuario según su perfil
class CalorieCalculator {
  /// Calcula el Metabolismo Basal (BMR) usando la fórmula Mifflin-St Jeor
  ///
  /// Mifflin-St Jeor (más precisa que Harris-Benedict):
  /// - Hombres: BMR = (10 × peso_kg) + (6.25 × altura_cm) - (5 × edad) + 5
  /// - Mujeres: BMR = (10 × peso_kg) + (6.25 × altura_cm) - (5 × edad) - 161
  ///
  /// Si no se proporciona edad/género, usa valores promedio estimados
  static double calculateBMR({
    required double weightKg,
    required int heightCm,
    int? age,
    String? gender,
  }) {
    // Valores por defecto si no se proporcionan
    final effectiveAge = age ?? 30; // Edad promedio
    final isMale =
        gender == null ||
        gender.toLowerCase() == 'hombre' ||
        gender.toLowerCase() == 'male';

    // Fórmula Mifflin-St Jeor
    final baseBMR = (10 * weightKg) + (6.25 * heightCm) - (5 * effectiveAge);

    return isMale ? baseBMR + 5 : baseBMR - 161;
  }

  /// Calcula el Gasto Energético Diario Total (TDEE)
  ///
  /// Aplica factor de actividad física sobre el BMR:
  /// - Sedentario (poco o nada de ejercicio): BMR × 1.2
  /// - Ligera (1-3 días/semana): BMR × 1.375
  /// - Moderada (3-5 días/semana): BMR × 1.55
  /// - Activa (6-7 días/semana): BMR × 1.725
  /// - Muy activa (deportista): BMR × 1.9
  static double calculateTDEE({
    required double bmr,
    String activityLevel = 'moderate',
  }) {
    final factor = _getActivityFactor(activityLevel);
    return bmr * factor;
  }

  static double _getActivityFactor(String level) {
    switch (level.toLowerCase()) {
      case 'sedentary':
      case 'sedentario':
        return 1.2;
      case 'light':
      case 'ligero':
      case 'ligera':
        return 1.375;
      case 'moderate':
      case 'moderado':
      case 'moderada':
        return 1.55;
      case 'active':
      case 'activo':
      case 'activa':
        return 1.725;
      case 'very_active':
      case 'muy_activo':
      case 'muy_activa':
        return 1.9;
      default:
        return 1.55; // Moderada por defecto
    }
  }

  /// Calcula las calorías objetivo diarias según el objetivo del usuario
  ///
  /// Ajustes sobre TDEE:
  /// - Pérdida de peso: TDEE - 500 kcal (pérdida de ~0.5kg/semana)
  /// - Mantenimiento: TDEE
  /// - Ganancia muscular: TDEE + 300-500 kcal (ganancia controlada)
  static int calculateDailyCalorieTarget({
    required double weightKg,
    required int heightCm,
    required String goal,
    int? age,
    String? gender,
    String activityLevel = 'moderate',
  }) {
    // Calcular BMR
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );

    // Calcular TDEE
    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);

    // Ajustar según objetivo
    final targetCalories = _applyGoalAdjustment(tdee, goal);

    return targetCalories.round();
  }

  static double _applyGoalAdjustment(double tdee, String goal) {
    final normalizedGoal = goal.toLowerCase();

    if (normalizedGoal.contains('perder') ||
        normalizedGoal.contains('pérdida') ||
        normalizedGoal.contains('adelgazar')) {
      // Déficit de 500 kcal/día = -0.5 kg/semana
      return tdee - 500;
    } else if (normalizedGoal.contains('ganar') ||
        normalizedGoal.contains('aumentar') ||
        normalizedGoal.contains('músculo') ||
        normalizedGoal.contains('musculo')) {
      // Superávit de 400 kcal/día = ganancia muscular controlada
      return tdee + 400;
    } else {
      // Mantenimiento
      return tdee;
    }
  }

  /// Calcula las calorías desde un UserProfile
  static int calculateFromProfile({
    required double weightKg,
    required int heightCm,
    required String goal,
    int? age,
    String? gender,
  }) {
    return calculateDailyCalorieTarget(
      weightKg: weightKg,
      heightCm: heightCm,
      goal: goal,
      age: age,
      gender: gender,
    );
  }
}
