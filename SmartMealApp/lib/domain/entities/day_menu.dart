import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart'; // Para usar DayOfWeek

class DayMenu {
  final DayOfWeek day;
  final Recipe? breakfast;
  final Recipe? lunch;
  final Recipe? dinner;
  final Recipe? snack;

  const DayMenu({
    required this.day,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snack,
  });

  int get totalCalories {
    int total = 0;
    if (breakfast != null) total += breakfast!.calories;
    if (lunch != null) total += lunch!.calories;
    if (dinner != null) total += dinner!.calories;
    if (snack != null) total += snack!.calories;
    return total;
  }

  List<Recipe> get allRecipes {
    final recipes = <Recipe>[];
    if (breakfast != null) recipes.add(breakfast!);
    if (lunch != null) recipes.add(lunch!);
    if (dinner != null) recipes.add(dinner!);
    if (snack != null) recipes.add(snack!);
    return recipes;
  }

  DayMenu copyWith({
    DayOfWeek? day,
    Recipe? breakfast,
    Recipe? lunch,
    Recipe? dinner,
    Recipe? snack,
  }) {
    return DayMenu(
      day: day ?? this.day,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snack: snack ?? this.snack,
    );
  }
}