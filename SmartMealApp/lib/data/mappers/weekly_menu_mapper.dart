import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/models/day_menu_model.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/core/utils/day_of_week_utils.dart';

class WeeklyMenuMapper {
  static Future<WeeklyMenu> toEntity(
    WeeklyMenuModel model,
    Future<Recipe?> Function(String) getRecipeById,
  ) async {
    final daysEntities = <DayMenu>[];
    for (final dayModel in model.days) {
      final recipes = <Recipe>[];
      for (final recipeId in dayModel.recipes) {
        final recipe = await getRecipeById(recipeId);
        if (recipe != null) recipes.add(recipe);
      }
      daysEntities.add(
        DayMenu(day: dayOfWeekFromString(dayModel.day), recipes: recipes),
      );
    }
    return WeeklyMenu(
      id: model.id,
      userId: model.userId,
      name: model.name ?? '',
      weekStartDate: model.weekStartDate,
      days: daysEntities,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static WeeklyMenuModel fromEntity(WeeklyMenu entity) {
    return WeeklyMenuModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      weekStartDate: entity.weekStartDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      days: entity.days.map((day) {
        return DayMenuModel(
          day: dayOfWeekToString(day.day),
          recipes: day.recipes.map((r) => r.id).toList(),
        );
      }).toList(),
    );
  }

  static Map<String, dynamic> toFirestore(WeeklyMenuModel model) {
    return {
      'userId': model.userId,
      'name': model.name,
      'weekStart': model.weekStartDate,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
      'days': model.days.map((day) {
        return {'day': day.day, 'recipes': day.recipes};
      }).toList(),
    };
  }
}
