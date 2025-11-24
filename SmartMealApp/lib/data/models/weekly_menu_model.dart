import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'day_menu_model.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';


class WeeklyMenuModel {
  final String id;
  final String userId;
  final DateTime weekStartDate;
  final List<DayMenuModel> days;

  WeeklyMenuModel({
    required this.id,
    required this.userId,
    required this.weekStartDate,
    required this.days,
  });

  factory WeeklyMenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeeklyMenuModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      weekStartDate: (data['semana'] is Timestamp)
          ? (data['semana'] as Timestamp).toDate()
          : DateTime.parse(data['semana']),
      days: (data['dias'] as List<dynamic>).map((dayData) {
        return DayMenuModel.fromMap(dayData as Map<String, dynamic>);
      }).toList(),
    );
  }
}

extension WeeklyMenuModelMapper on WeeklyMenuModel {
  Future<WeeklyMenu> toEntity(Future<Recipe?> Function(String) getRecipeById) async {
    final daysEntities = <DayMenu>[];
    for (final dayModel in days) {
      final breakfast = dayModel.breakfast != null ? await getRecipeById(dayModel.breakfast!) : null;
      final lunch = dayModel.lunch != null ? await getRecipeById(dayModel.lunch!) : null;
      final dinner = dayModel.dinner != null ? await getRecipeById(dayModel.dinner!) : null;
      final snack = dayModel.snack != null ? await getRecipeById(dayModel.snack!) : null;
      daysEntities.add(DayMenu(
        day: _parseDayOfWeek(dayModel.day),
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        snack: snack,
      ));
    }
    return WeeklyMenu(
      id: id,
      userId: userId,
      name: '', // Si tienes nombre, ponlo aquí
      weekStartDate: weekStartDate,
      days: daysEntities,
      createdAt: weekStartDate,
      updatedAt: null,
    );
  }

  DayOfWeek _parseDayOfWeek(String day) {
    switch (day.toLowerCase()) {
      case 'lunes': return DayOfWeek.monday;
      case 'martes': return DayOfWeek.tuesday;
      case 'miércoles': return DayOfWeek.wednesday;
      case 'jueves': return DayOfWeek.thursday;
      case 'viernes': return DayOfWeek.friday;
      case 'sábado': return DayOfWeek.saturday;
      case 'domingo': return DayOfWeek.sunday;
      default: return DayOfWeek.monday;
    }
  }
}