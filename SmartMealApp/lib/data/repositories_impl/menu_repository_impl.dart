import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/data/datasources/remote/menu_datasource.dart';
import 'package:smartmeal/data/mappers/menu_item_mapper.dart';
import 'package:smartmeal/core/errors/errors.dart';

/// Implementación del repositorio de items de menú.
///
/// Responsabilidad:
/// - CRUD de items de menú en Firestore
/// - Mapeo entre modelos y entidades
///
/// Nota:
/// - **NO confundir con WeeklyMenuRepository**
/// - MenuItem: item individual del menú (ej: "Pollo al horno")
/// - WeeklyMenu: menú semanal completo con 28 recetas
///
/// Operaciones:
/// - **getMenuItems**: obtiene todos los items
/// - **getRecommendedMenuItems**: obtiene items recomendados (límite)
/// - **getMenuItem**: obtiene item por ID
/// - **createMenuItem**: crea nuevo item
/// - **updateMenuItem**: actualiza item existente
/// - **deleteMenuItem**: elimina item
///
/// Uso:
/// ```dart
/// final repo = MenuRepositoryImpl(dataSource: ds);
///
/// // Obtener recomendados
/// final recommended = await repo.getRecommendedMenuItems(5);
///
/// // Crear item
/// await repo.createMenuItem(MenuItem(...));
/// ```
class MenuRepositoryImpl implements MenuRepository {
  final MenuDataSource _dataSource;

  MenuRepositoryImpl({required MenuDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<List<MenuItem>> getMenuItems() async {
    final data = await _dataSource.getMenuItems();
    return data.map((item) => MenuItemMapper.fromFirestore(item)).toList();
  }

  @override
  Future<List<MenuItem>> getRecommendedMenuItems(int limit) async {
    final data = await _dataSource.getRecommendedMenuItems(limit);
    return data.map((item) => MenuItemMapper.fromFirestore(item)).toList();
  }

  @override
  Future<MenuItem> getMenuItem(String id) async {
    final data = await _dataSource.getMenuItem(id);
    if (data == null) throw NotFoundFailure('Menú no encontrado');
    return MenuItemMapper.fromFirestore(data);
  }

  @override
  Future<void> createMenuItem(MenuItem menuItem) async {
    await _dataSource.createMenuItem(
      menuItem.id,
      MenuItemMapper.toFirestoreCreate(menuItem),
    );
  }

  @override
  Future<void> updateMenuItem(MenuItem menuItem) async {
    await _dataSource.updateMenuItem(
      menuItem.id,
      MenuItemMapper.toFirestore(menuItem),
    );
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    await _dataSource.deleteMenuItem(id);
  }

  @override
  Future<List<MenuItem>> getLatestWeeklyMenu() async {
    final rawData = await _dataSource.getLatestWeeklyMenu();
    return rawData.map((data) => MenuItemMapper.fromFirestore(data)).toList();
  }
}
