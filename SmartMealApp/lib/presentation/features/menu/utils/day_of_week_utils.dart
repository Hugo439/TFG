import 'package:smartmeal/domain/entities/weekly_menu.dart';

String dayOfWeekToString(DayOfWeek day) {
  switch (day) {
    case DayOfWeek.monday:
      return 'Lunes';
    case DayOfWeek.tuesday:
      return 'Martes';
    case DayOfWeek.wednesday:
      return 'Miércoles';
    case DayOfWeek.thursday:
      return 'Jueves';
    case DayOfWeek.friday:
      return 'Viernes';
    case DayOfWeek.saturday:
      return 'Sábado';
    case DayOfWeek.sunday:
      return 'Domingo';
  }
}
