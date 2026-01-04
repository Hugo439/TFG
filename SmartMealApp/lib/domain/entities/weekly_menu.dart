import 'package:smartmeal/domain/entities/day_menu.dart';

/// Enumeración de los días de la semana.
///
/// Se usa para identificar y ordenar los días del menú semanal.
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Entidad que representa un menú completo de una semana.
///
/// Contiene menús diarios organizados por día, junto con metadatos
/// como fecha de inicio, nombre y estadísticas calóricas.
///
/// **Responsabilidades:**
/// - Agrupar menús de 7 días consecutivos
/// - Calcular totales y promedios calóricos semanales
/// - Proveer contexto temporal (semana de inicio)
/// - Identificar al usuario propietario
class WeeklyMenu {
  /// ID único del menú semanal en Firestore.
  final String id;

  /// ID del usuario propietario del menú.
  final String userId;

  /// Nombre descriptivo del menú (ej: "Semana del 15 Ene").
  final String name;

  /// Fecha de inicio de la semana (típicamente lunes).
  final DateTime weekStartDate;

  /// Lista de menús diarios, uno por cada día de la semana.
  final List<DayMenu> days;

  /// Timestamp de creación del menú.
  final DateTime createdAt;

  /// Timestamp de última actualización (opcional).
  final DateTime? updatedAt;

  /// Crea una instancia de [WeeklyMenu].
  const WeeklyMenu({
    required this.id,
    required this.userId,
    required this.name,
    required this.weekStartDate,
    required this.days,
    required this.createdAt,
    this.updatedAt,
  });

  /// Calcula el total de calorías de toda la semana.
  ///
  /// Suma las calorías de todos los días del menú.
  int get totalWeeklyCalories =>
      days.fold(0, (sum, day) => sum + day.totalCalories);

  /// Calcula el promedio de calorías diarias.
  ///
  /// Útil para verificar que el menú se mantiene cerca del objetivo.
  /// Retorna 0 si no hay días en el menú.
  double get avgDailyCalories {
    if (days.isEmpty) return 0;
    return totalWeeklyCalories / days.length;
  }

  /// Crea una copia del menú con campos actualizados.
  ///
  /// Permite modificaciones inmutables del menú.
  WeeklyMenu copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? weekStartDate,
    List<DayMenu>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyMenu(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
