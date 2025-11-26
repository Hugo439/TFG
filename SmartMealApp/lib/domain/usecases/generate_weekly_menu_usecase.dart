import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/utils/formatters.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/value_objects/recipe_name.dart';
import 'package:smartmeal/domain/value_objects/recipe_description.dart';
import 'package:smartmeal/data/datasources/remote/groq_recipe_datasource.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';


class GenerateWeeklyMenuParams {
  final String userId;
  final UserProfile userProfile;
  final DateTime startDate;
  final int targetCaloriesPerDay;
  final List<String> excludedTags;

  const GenerateWeeklyMenuParams({
    required this.userId,
    required this.userProfile,
    required this.startDate,
    required this.targetCaloriesPerDay,
    this.excludedTags = const [],
  });
}

class GenerateWeeklyMenuUseCase implements UseCase<WeeklyMenu, GenerateWeeklyMenuParams> {
  final WeeklyMenuRepository _menuRepository;
  final GroqRecipeDataSource _aiDataSource;

  GenerateWeeklyMenuUseCase(this._menuRepository, this._aiDataSource);

  @override
  Future<WeeklyMenu> call(GenerateWeeklyMenuParams params) async {
    final caloriesPerMeal = (params.targetCaloriesPerDay / 4).round();

    // Generar recetas con IA para cada tipo de comida
    final breakfastsData = await _aiDataSource.generateRecipes(
      mealType: 'breakfast',
      targetCaloriesPerMeal: caloriesPerMeal,
      excludedTags: params.excludedTags,
      userGoal: params.userProfile.goal.displayName,
      count: 7,
    );
    final lunchesData = await _aiDataSource.generateRecipes(
      mealType: 'lunch',
      targetCaloriesPerMeal: caloriesPerMeal,
      excludedTags: params.excludedTags,
      userGoal: params.userProfile.goal.displayName,
      count: 7,
    );
    final dinnersData = await _aiDataSource.generateRecipes(
      mealType: 'dinner',
      targetCaloriesPerMeal: caloriesPerMeal,
      excludedTags: params.excludedTags,
      userGoal: params.userProfile.goal.displayName,
      count: 7,
    );
    final snacksData = await _aiDataSource.generateRecipes(
      mealType: 'snack',
      targetCaloriesPerMeal: (caloriesPerMeal * 0.5).round(),
      excludedTags: params.excludedTags,
      userGoal: params.userProfile.goal.displayName,
      count: 7,
    );

    // Convertir datos a entidades Recipe (solo los campos principales)
    final breakfasts = _mapToRecipes(breakfastsData, MealType.breakfast);
    final lunches = _mapToRecipes(lunchesData, MealType.lunch);
    final dinners = _mapToRecipes(dinnersData, MealType.dinner);
    final snacks = _mapToRecipes(snacksData, MealType.snack);

    // Crear menú diario para cada día
    final days = <DayMenu>[];
    for (int i = 0; i < 7; i++) {
      final recipes = <Recipe>[];
      if (breakfasts.length > i) recipes.add(breakfasts[i]);
      if (lunches.length > i) recipes.add(lunches[i]);
      if (dinners.length > i) recipes.add(dinners[i]);
      if (snacks.length > i) recipes.add(snacks[i]);
      days.add(DayMenu(
        day: DayOfWeek.values[i],
        recipes: recipes,
      ));
    }

    // Crear menú semanal
    final menu = WeeklyMenu(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: params.userId,
      name: 'Menú ${Formatters.formatShortDate(params.startDate)}',
      weekStartDate: params.startDate,
      days: days,
      createdAt: DateTime.now(),
    );

    // Guardar en Firestore
    await _menuRepository.saveMenu(menu);

    return menu;
  }

  List<Recipe> _mapToRecipes(List<Map<String, dynamic>> data, MealType mealType) {
    return data.map((recipeData) {
      return Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            recipeData['name'].toString().hashCode.toString(),
        name: RecipeName(recipeData['name'] as String),
        description: RecipeDescription(recipeData['description'] as String),
        ingredients: List<String>.from(recipeData['ingredients'] as List),
        calories: (recipeData['calories'] as num).toInt(),
        mealType: mealType,
      );
    }).toList();
  }
}