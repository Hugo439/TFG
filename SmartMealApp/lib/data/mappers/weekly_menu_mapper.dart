import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/models/day_menu_model.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/day_menu.dart'; // Importa la nueva entidad
import 'package:smartmeal/domain/entities/recipe.dart';


class WeeklyMenuMapper {
  static Future<WeeklyMenu> toEntity(
    WeeklyMenuModel model,
    Future<Recipe?> Function(String) getRecipeById,
  ) async {
    final daysEntities = <DayMenu>[];
    for (final dayModel in model.days) {
      final breakfast = dayModel.breakfast != null && dayModel.breakfast != ''
          ? await getRecipeById(dayModel.breakfast!)
          : null;
      final lunch = dayModel.lunch != null && dayModel.lunch != ''
          ? await getRecipeById(dayModel.lunch!)
          : null;
      final dinner = dayModel.dinner != null && dayModel.dinner != ''
          ? await getRecipeById(dayModel.dinner!)
          : null;
      final snack = dayModel.snack != null && dayModel.snack != ''
          ? await getRecipeById(dayModel.snack!)
          : null;
      daysEntities.add(DayMenu(
        day: _parseDayOfWeek(dayModel.day),
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        snack: snack,
      ));
    }
    return WeeklyMenu(
      id: model.id,
      userId: model.userId,
      name: '', // Si tienes nombre, ponlo aquí
      weekStartDate: model.weekStartDate,
      days: daysEntities,
      createdAt: model.weekStartDate,
      updatedAt: null,
    );
  }

  static WeeklyMenuModel fromEntity(WeeklyMenu entity) {
    return WeeklyMenuModel(
      id: entity.id,
      userId: entity.userId,
      weekStartDate: entity.weekStartDate,
      days: entity.days.map((day) {
        return DayMenuModel(
          day: _dayOfWeekToString(day.day),
          breakfast: day.breakfast?.id,
          lunch: day.lunch?.id,
          dinner: day.dinner?.id,
          snack: day.snack?.id,
        );
      }).toList(),
    );
  }

  static Map<String, dynamic> toFirestore(WeeklyMenuModel model) {
    return {
      'userId': model.userId,
      'semana': model.weekStartDate.toIso8601String(),
      'dias': model.days.map((day) {
        return {
          'dia': day.day,
          'breakfast': day.breakfast,
          'lunch': day.lunch,
          'dinner': day.dinner,
          'snack': day.snack,
        };
      }).toList(),
    };
  }

  static DayOfWeek _parseDayOfWeek(String day) {
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

  static String _dayOfWeekToString(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday: return 'lunes';
      case DayOfWeek.tuesday: return 'martes';
      case DayOfWeek.wednesday: return 'miércoles';
      case DayOfWeek.thursday: return 'jueves';
      case DayOfWeek.friday: return 'viernes';
      case DayOfWeek.saturday: return 'sábado';
      case DayOfWeek.sunday: return 'domingo';
    }
  }
}