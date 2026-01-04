import 'package:smartmeal/domain/entities/weekly_menu.dart';

/// Contrato para operaciones CRUD sobre menús semanales.
///
/// Gestiona la persistencia de [WeeklyMenu] en Firestore, incluyendo:
/// - Obtención de menús del usuario
/// - Guardado de nuevos menús generados
/// - Actualización de menús existentes
/// - Eliminación de menús
/// - Búsqueda del menú activo de la semana actual
///
/// Los menús semanales contienen 7 días de recetas organizadas
/// por tipo de comida (desayuno, comida, cena, snack).
abstract class WeeklyMenuRepository {
  /// Obtiene todos los menús de un usuario.
  ///
  /// **Parámetro:**
  /// - [userId]: ID del usuario
  ///
  /// **Retorna:** Lista de menús ordenados por fecha (más reciente primero).
  Future<List<WeeklyMenu>> getUserMenus(String userId);

  /// Obtiene un menú específico por su ID.
  ///
  /// **Parámetro:**
  /// - [id]: ID del menú
  ///
  /// **Lanza:** [NotFoundFailure] si el menú no existe.
  Future<WeeklyMenu> getMenuById(String id);

  /// Guarda un nuevo menú semanal en Firestore.
  ///
  /// **Parámetro:**
  /// - [menu]: Menú a guardar
  Future<void> saveMenu(WeeklyMenu menu);

  /// Actualiza un menú existente.
  ///
  /// **Parámetro:**
  /// - [menu]: Menú con datos actualizados
  Future<void> updateMenu(WeeklyMenu menu);

  /// Elimina un menú permanentemente.
  ///
  /// **Parámetro:**
  /// - [id]: ID del menú a eliminar
  Future<void> deleteMenu(String id);

  /// Obtiene el menú de la semana actual del usuario.
  ///
  /// **Parámetro:**
  /// - [userId]: ID del usuario
  ///
  /// **Retorna:** El menú actual o `null` si no existe.
  Future<WeeklyMenu?> getCurrentWeekMenu(String userId);

  /// Obtiene todos los menús semanales del usuario.
  ///
  /// **Parámetro:**
  /// - [userId]: ID del usuario
  ///
  /// **Retorna:** Lista completa de menús.
  ///
  /// **Nota:** Método duplicado de getUserMenus, considerar eliminar.
  Future<List<WeeklyMenu>> getWeeklyMenus(String userId);
}

// TODO: mirar si se usa, yo creo que no
