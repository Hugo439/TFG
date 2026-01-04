import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/models/day_menu_model.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/core/utils/day_of_week_utils.dart';

/// Mapper para convertir entre WeeklyMenu (dominio) y WeeklyMenuModel (datos).
///
/// Responsabilidades:
/// - **toEntity**: Model → Entity (requiere resolver IDs de recetas → Recipe entities)
/// - **fromEntity**: Entity → Model (extrae IDs de recetas)
/// - **toFirestore**: Model → Map para persistencia
///
/// Características especiales:
/// - toEntity es async porque debe cargar recetas completas desde Firestore
/// - Recibe callback getRecipeById para resolver dependencias
/// - Filtra recetas no encontradas (null) de forma silenciosa
///
/// Estructura Firestore:
/// ```json
/// {
///   "userId": "user123",
///   "name": "Menú Semana 1",
///   "weekStart": "2024-01-01T00:00:00.000Z",
///   "days": [
///     {"day": "monday", "recipes": ["recipeId1", "recipeId2", ...]},
///     {"day": "tuesday", "recipes": [...]},
///     ...
///   ],
///   "createdAt": "2024-01-01T10:00:00.000Z",
///   "updatedAt": "2024-01-05T15:30:00.000Z"
/// }
/// ```
class WeeklyMenuMapper {
  /// Convierte WeeklyMenuModel a WeeklyMenu resolviendo IDs de recetas.
  ///
  /// [model] - Modelo desde Firestore con IDs de recetas.
  /// [getRecipeById] - Callback async para cargar Recipe desde Firestore.
  ///
  /// Returns: WeeklyMenu con entidades Recipe completas.
  ///
  /// Proceso:
  /// 1. Por cada DayMenuModel en model.days
  /// 2. Resolver cada recipeId → Recipe usando getRecipeById
  /// 3. Filtrar recetas no encontradas (null)
  /// 4. Construir DayMenu con recetas resueltas
  /// 5. Retornar WeeklyMenu completo
  ///
  /// Nota: Si una receta no se encuentra, se omite silenciosamente.
  static Future<WeeklyMenu> toEntity(
    WeeklyMenuModel model,
    Future<Recipe?> Function(String) getRecipeById,
  ) async {
    final daysEntities = <DayMenu>[];
    for (final dayModel in model.days) {
      final recipes = <Recipe>[];
      for (final recipeId in dayModel.recipes) {
        final recipe = await getRecipeById(recipeId);
        if (recipe != null) recipes.add(recipe);
      }
      daysEntities.add(
        DayMenu(day: dayOfWeekFromString(dayModel.day), recipes: recipes),
      );
    }
    return WeeklyMenu(
      id: model.id,
      userId: model.userId,
      name: model.name ?? '',
      weekStartDate: model.weekStartDate,
      days: daysEntities,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convierte WeeklyMenu a WeeklyMenuModel extrayendo IDs de recetas.
  ///
  /// [entity] - Menú semanal del dominio con entidades Recipe completas.
  ///
  /// Returns: Modelo listo para Firestore con solo IDs de recetas.
  ///
  /// Extracción:
  /// - Recipe entities → lista de IDs (recipe.id)
  /// - DayOfWeek enum → string usando day_of_week_utils
  static WeeklyMenuModel fromEntity(WeeklyMenu entity) {
    return WeeklyMenuModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      weekStartDate: entity.weekStartDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      days: entity.days.map((day) {
        return DayMenuModel(
          day: dayOfWeekToString(day.day),
          recipes: day.recipes.map((r) => r.id).toList(),
        );
      }).toList(),
    );
  }

  /// Convierte WeeklyMenuModel a Map para Firestore.
  ///
  /// [model] - Modelo con IDs de recetas.
  ///
  /// Returns: Map compatible con Firestore.
  ///
  /// Nota: No incluye el campo 'id' porque Firestore usa document ID.
  static Map<String, dynamic> toFirestore(WeeklyMenuModel model) {
    return {
      'userId': model.userId,
      'name': model.name,
      'weekStart': model.weekStartDate,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
      'days': model.days.map((day) {
        return {'day': day.day, 'recipes': day.recipes};
      }).toList(),
    };
  }
}
