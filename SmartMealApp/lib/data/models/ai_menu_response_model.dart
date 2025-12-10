import 'package:smartmeal/data/models/recipe_data_model.dart';
import 'package:smartmeal/data/models/day_menu_data_model.dart';

class AiMenuResponseModel {
  final List<RecipeDataModel> recipes;
  final Map<String, DayMenuDataModel> weeklyMenu;

  AiMenuResponseModel({
    required this.recipes,
    required this.weeklyMenu,
  });

  factory AiMenuResponseModel.fromJson(Map<String, dynamic> json) {
    final recipesJson = json['recipes'] as List;
    final recipes = recipesJson
        .map((r) => RecipeDataModel.fromJson(r as Map<String, dynamic>))
        .toList();

    final weeklyMenuJson = json['weeklyMenu'] as Map<String, dynamic>;
    final weeklyMenu = <String, DayMenuDataModel>{};
    
    weeklyMenuJson.forEach((day, data) {
      weeklyMenu[day] = DayMenuDataModel.fromJson(data as Map<String, dynamic>);
    });

    return AiMenuResponseModel(
      recipes: recipes,
      weeklyMenu: weeklyMenu,
    );
  }
}