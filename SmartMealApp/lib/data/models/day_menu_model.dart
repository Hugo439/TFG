class DayMenuModel {
  final String day;
  final List<String> recipes;

  DayMenuModel({required this.day, required this.recipes});

  factory DayMenuModel.fromMap(Map<String, dynamic> map) {
    try {
      return DayMenuModel(
        day: map['day'] ?? '',
        recipes: List<String>.from(map['recipes'] ?? []),
      );
    } catch (e) {
      throw Exception('Error al convertir DayMenuModel: $e');
    }
  }
}
