class RecipeDataModel {
  final String name;
  final String description;
  final List<String> ingredients;
  final int calories;
  final String mealType;
  final List<String> steps;

  RecipeDataModel({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.mealType,
    required this.steps,
  });

  factory RecipeDataModel.fromJson(Map<String, dynamic> json) {
    return RecipeDataModel(
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List)
          .map((e) => e.toString())
          .toList(),
      calories: json['calories'] as int,
      mealType: json['mealType'] as String,
      steps: (json['steps'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
