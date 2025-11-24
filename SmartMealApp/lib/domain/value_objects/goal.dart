import 'package:smartmeal/domain/value_objects/value_object.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

enum GoalType {
  loseWeight('Perder peso'),
  maintainWeight('Mantener peso'),
  gainMuscle('Ganar masa muscular'),
  healthyEating('Alimentación saludable');

  final String displayName;
  const GoalType(this.displayName);
  
  static GoalType fromString(String value) {
    return GoalType.values.firstWhere(
      (goal) => goal.displayName == value,
      orElse: () => GoalType.loseWeight,
    );
  }
}

class Goal extends ValueObject<GoalType> {
  Goal(super.value);
  
  factory Goal.fromString(String value) {
    return Goal(GoalType.fromString(value));
  }
  
  String get displayName => value.displayName;
  
  // Lógica de negocio: calorías recomendadas según objetivo
  double getCalorieMultiplier() {
    switch (value) {
      case GoalType.loseWeight:
        return 0.85; // -15% calorías
      case GoalType.maintainWeight:
        return 1.0;  // mantener
      case GoalType.gainMuscle:
        return 1.15; // +15% calorías
      case GoalType.healthyEating:
        return 1.0;  // mantener
    }
  }
}