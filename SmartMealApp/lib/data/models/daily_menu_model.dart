class DailyMenuModel {
  final String day;
  final Map<String, String> meals; // { "breakfast": recipeId, ... }

  DailyMenuModel({
    required this.day,
    required this.meals,
  });

  factory DailyMenuModel.fromMap(Map<String, dynamic> map) {
    return DailyMenuModel(
      day: map['day'] ?? '',
      meals: Map<String, String>.from(map['meals'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'meals': meals,
  };
}

//TODO: no se usa 