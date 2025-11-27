class DailyMenu {
  final String day;
  final Map<String, String> meals; // { "breakfast": recipeId, ... }

  DailyMenu({
    required this.day,
    required this.meals,
  });
}
//TODO: NO SE USA