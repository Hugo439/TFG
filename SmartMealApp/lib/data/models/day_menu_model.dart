import 'package:smartmeal/core/errors/errors.dart';

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
      throw ServerFailure('Error al convertir DayMenuModel: $e');
    }
  }
}
