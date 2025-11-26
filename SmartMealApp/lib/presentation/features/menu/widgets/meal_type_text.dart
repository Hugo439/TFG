import 'package:smartmeal/domain/entities/recipe.dart';

extension MealTypeText on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast: return 'Desayuno';
      case MealType.lunch: return 'Comida';
      case MealType.dinner: return 'Cena';
      case MealType.snack: return 'Snack';
    }
  }
}