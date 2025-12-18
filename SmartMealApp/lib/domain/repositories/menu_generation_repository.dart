import 'package:smartmeal/domain/entities/weekly_menu.dart';

abstract class MenuGenerationRepository {
  Future<WeeklyMenu> generateWeeklyMenu({
    required String userId,
    required int targetCaloriesPerDay,
    required List<String> allergies,
    required String userGoal,
  });

  Future<List<String>> generateRecipeSteps({
    required String recipeName,
    required List<String> ingredients,
    required String description,
  });
}
