import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/recipe.dart';

extension MealTypeIcon on MealType {
  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.fastfood;
    }
  }
}