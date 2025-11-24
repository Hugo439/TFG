import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class WeeklyMenu {
  final String id;
  final String userId;
  final String name;
  final DateTime weekStartDate;
  final List<DayMenu> days;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WeeklyMenu({
    required this.id,
    required this.userId,
    required this.name,
    required this.weekStartDate,
    required this.days,
    required this.createdAt,
    this.updatedAt,
  });

  int get totalWeeklyCalories {
    return days.fold(0, (sum, day) => sum + day.totalCalories);
  }

  double get avgDailyCalories {
    return totalWeeklyCalories / 7;
  }

  List<Recipe> get allRecipes {
    final recipes = <Recipe>[];
    for (final day in days) {
      recipes.addAll(day.allRecipes);
    }
    return recipes;
  }

  WeeklyMenu copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? weekStartDate,
    List<DayMenu>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyMenu(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}