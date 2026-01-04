import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

String mealTypeToString(MealType type) {
  switch (type) {
    case MealType.breakfast:
      return 'breakfast';
    case MealType.lunch:
      return 'lunch';
    case MealType.dinner:
      return 'dinner';
    case MealType.snack:
      return 'snack';
  }
}

MealType mealTypeFromString(String value) {
  switch (value) {
    case 'breakfast':
      return MealType.breakfast;
    case 'lunch':
      return MealType.lunch;
    case 'dinner':
      return MealType.dinner;
    case 'snack':
      return MealType.snack;
    default:
      return MealType.breakfast;
  }
}

String getLocalizedMealType(BuildContext context, MealType type) {
  final l10n = context.l10n;
  switch (type) {
    case MealType.breakfast:
      return l10n.mealTypeBreakfast;
    case MealType.lunch:
      return l10n.mealTypeLunch;
    case MealType.dinner:
      return l10n.mealTypeDinner;
    case MealType.snack:
      return l10n.mealTypeSnack;
  }
}
