class DayMenuModel {
  final String day;
  final String? breakfast;
  final String? lunch;
  final String? dinner;
  final String? snack;

  DayMenuModel({
    required this.day,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snack,
  });

  factory DayMenuModel.fromMap(Map<String, dynamic> map) {
    return DayMenuModel(
      day: map['dia'] ?? '',
      breakfast: map['breakfast'],
      lunch: map['lunch'],
      dinner: map['dinner'],
      snack: map['snack'],
    );
  }
}