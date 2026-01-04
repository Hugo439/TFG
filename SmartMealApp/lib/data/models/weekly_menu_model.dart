import 'package:cloud_firestore/cloud_firestore.dart';
import 'day_menu_model.dart';
import 'package:smartmeal/core/errors/errors.dart';

/// Modelo de datos para WeeklyMenu compatible con Firestore.
///
/// Responsabilidades:
/// - Serialización desde Firestore
/// - Almacenar estructura del menú semanal
/// - Referencias a recetas por ID (no objetos completos)
///
/// Campos:
/// - **id**: ID único del menú (userId_menu_timestamp)
/// - **userId**: propietario del menú
/// - **name**: nombre opcional del menú
/// - **weekStartDate**: fecha de inicio de la semana (lunes)
/// - **createdAt, updatedAt**: timestamps
/// - **days**: lista de 7 DayMenuModel (lunes a domingo)
///
/// Estructura en Firestore:
/// ```json
/// {
///   "userId": "user123",
///   "name": "Menú Semana 1",
///   "weekStart": "2024-01-01T00:00:00.000Z",
///   "createdAt": "2024-01-01T10:00:00.000Z",
///   "updatedAt": "2024-01-05T15:30:00.000Z",
///   "days": [
///     {"day": "monday", "recipes": ["recipeId1", "recipeId2", "recipeId3", "recipeId4"]},
///     {"day": "tuesday", "recipes": [...]},
///     ...
///   ]
/// }
/// ```
///
/// Nota: Solo almacena IDs de recetas, no objetos Recipe completos.
/// Para obtener recetas completas, usar WeeklyMenuMapper.toEntity().
class WeeklyMenuModel {
  final String id;
  final String userId;
  final String? name;
  final DateTime weekStartDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<DayMenuModel> days;

  WeeklyMenuModel({
    required this.id,
    required this.userId,
    this.name,
    required this.weekStartDate,
    required this.createdAt,
    this.updatedAt,
    required this.days,
  });

  /// Crea modelo desde DocumentSnapshot de Firestore.
  ///
  /// Lanza ServerFailure si hay error en conversión.
  ///
  /// Parsea:
  /// - Timestamps a DateTime
  /// - Lista de days a List<DayMenuModel>
  factory WeeklyMenuModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return WeeklyMenuModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        name: data['name'],
        weekStartDate: (data['weekStart'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        days: (data['days'] as List<dynamic>)
            .map((d) => DayMenuModel.fromMap(d as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw ServerFailure('Error al convertir WeeklyMenuModel: $e');
    }
  }
}
