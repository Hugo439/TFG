import 'package:smartmeal/domain/entities/recipe.dart';

String mealTypeToString(MealType type) {
  switch (type) {
    case MealType.breakfast: return 'breakfast';
    case MealType.lunch: return 'lunch';
    case MealType.dinner: return 'dinner';
    case MealType.snack: return 'snack';
  }
}

MealType mealTypeFromString(String value) {
  switch (value) {
    case 'breakfast': return MealType.breakfast;
    case 'lunch': return MealType.lunch;
    case 'dinner': return MealType.dinner;
    case 'snack': return MealType.snack;
    default: return MealType.breakfast;
  }
}
