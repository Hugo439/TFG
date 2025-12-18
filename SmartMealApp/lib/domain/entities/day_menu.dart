import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';

class DayMenu {
  final DayOfWeek day;
  final List<Recipe> recipes;

  const DayMenu({required this.day, required this.recipes});

  int get totalCalories => recipes.fold(0, (sum, r) => sum + r.calories);

  DayMenu copyWith({DayOfWeek? day, List<Recipe>? recipes}) {
    return DayMenu(day: day ?? this.day, recipes: recipes ?? this.recipes);
  }
}
