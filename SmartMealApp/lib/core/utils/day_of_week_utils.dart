import 'package:smartmeal/domain/entities/weekly_menu.dart';

DayOfWeek dayOfWeekFromString(String day) {
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

String dayOfWeekToString(DayOfWeek day) {
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