/// Calculadora de necesidades calóricas personalizadas según perfil de usuario.
///
/// Utiliza fórmulas científicas validadas para estimar el gasto energético
/// y ajustarlo según objetivos nutricionales específicos.
class CalorieCalculator {
  /// Calcula el Metabolismo Basal (BMR) usando la fórmula Mifflin-St Jeor.
  ///
  /// El BMR es la cantidad de calorías que el cuerpo quema en reposo absoluto
  /// para mantener funciones vitales (respiración, circulación, etc).
  ///
  /// **Fórmula Mifflin-St Jeor** (más precisa que Harris-Benedict):
  /// - Hombres: BMR = (10 × peso_kg) + (6.25 × altura_cm) - (5 × edad) + 5
  /// - Mujeres: BMR = (10 × peso_kg) + (6.25 × altura_cm) - (5 × edad) - 161
  ///
  /// **Parámetros:**
  /// - [weightKg]: Peso del usuario en kilogramos
  /// - [heightCm]: Altura del usuario en centímetros
  /// - [age]: Edad del usuario (opcional, usa 30 por defecto)
  /// - [gender]: 'hombre'/'male' o 'mujer'/'female' (opcional, asume hombre)
  ///
  /// **Retorna:** El BMR en kilocalorías por día
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final bmr = CalorieCalculator.calculateBMR(
  ///   weightKg: 70,
  ///   heightCm: 175,
  ///   age: 25,
  ///   gender: 'hombre',
  /// );
  /// // bmr ≈ 1680 kcal/día
  /// ```
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

  /// Calcula el Gasto Energético Diario Total (TDEE).
  ///
  /// El TDEE multiplica el BMR por un factor de actividad física para estimar
  /// las calorías totales quemadas en un día típico.
  ///
  /// **Factores de actividad:**
  /// - Sedentario (poco o nada de ejercicio): BMR × 1.2
  /// - Ligera (1-3 días/semana): BMR × 1.375
  /// - Moderada (3-5 días/semana): BMR × 1.55
  /// - Activa (6-7 días/semana): BMR × 1.725
  /// - Muy activa (deportista/trabajo físico): BMR × 1.9
  ///
  /// **Parámetros:**
  /// - [bmr]: El Metabolismo Basal calculado previamente
  /// - [activityLevel]: Nivel de actividad (sedentario, ligero, moderado, activo, muy_activo)
  ///
  /// **Retorna:** El TDEE en kilocalorías por día
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final tdee = CalorieCalculator.calculateTDEE(
  ///   bmr: 1680,
  ///   activityLevel: 'moderate',
  /// );
  /// // tdee ≈ 2604 kcal/día
  /// ```
  static double calculateTDEE({
    required double bmr,
    String activityLevel = 'moderate',
  }) {
    final factor = _getActivityFactor(activityLevel);
    return bmr * factor;
  }

  /// Obtiene el factor multiplicador según nivel de actividad física.
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

  /// Calcula las calorías objetivo diarias según el objetivo nutricional.
  ///
  /// Ajusta el TDEE con déficit o superávit calórico según el objetivo:
  /// - **Pérdida de peso**: TDEE - 500 kcal (pérdida de ~0.5kg/semana)
  /// - **Mantenimiento**: TDEE sin ajustes
  /// - **Ganancia muscular**: TDEE + 400 kcal (ganancia controlada)
  ///
  /// **Parámetros:**
  /// - [weightKg]: Peso en kilogramos
  /// - [heightCm]: Altura en centímetros
  /// - [goal]: Objetivo nutricional del usuario
  /// - [age]: Edad (opcional)
  /// - [gender]: Género (opcional)
  /// - [activityLevel]: Nivel de actividad física (opcional, por defecto 'moderate')
  ///
  /// **Retorna:** Calorías objetivo diarias (redondeado a entero)
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final targetCalories = CalorieCalculator.calculateDailyCalorieTarget(
  ///   weightKg: 70,
  ///   heightCm: 175,
  ///   goal: 'Perder peso',
  ///   age: 25,
  ///   gender: 'hombre',
  ///   activityLevel: 'moderate',
  /// );
  /// // targetCalories ≈ 2104 kcal/día (TDEE - 500)
  /// ```
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

  /// Aplica ajuste calórico según el objetivo del usuario.
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

  /// Calcula calorías desde un perfil de usuario completo.
  ///
  /// Método de conveniencia que extrae datos del perfil de usuario
  /// y calcula el objetivo calórico automáticamente.
  ///
  /// **Parámetros:**
  /// - [weightKg]: Peso del perfil
  /// - [heightCm]: Altura del perfil
  /// - [goal]: Objetivo del perfil
  /// - [age]: Edad del perfil (opcional)
  /// - [gender]: Género del perfil (opcional)
  ///
  /// **Retorna:** Calorías objetivo diarias
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
