import 'package:smartmeal/core/errors/errors.dart';

/// Modelo de datos para un día del menú semanal.
///
/// Responsabilidad:
/// - Almacenar referencias a recetas de un día específico
///
/// Campos:
/// - **day**: nombre del día (monday, tuesday, wednesday, etc.)
/// - **recipes**: lista de IDs de recetas del día (4 recetas típicamente)
///
/// Formato en Firestore:
/// ```json
/// {
///   "day": "monday",
///   "recipes": ["recipeId1", "recipeId2", "recipeId3", "recipeId4"]
/// }
/// ```
///
/// Orden de recetas:
/// 1. Desayuno (breakfast)
/// 2. Comida (lunch)
/// 3. Merienda (snack)
/// 4. Cena (dinner)
///
/// Nota: Solo almacena IDs de recetas, no objetos Recipe completos.
class DayMenuModel {
  final String day;
  final List<String> recipes;

  DayMenuModel({required this.day, required this.recipes});

  /// Parsea DayMenuModel desde Map.
  ///
  /// Lanza ServerFailure si hay error en conversión.
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
