import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/data/datasources/remote/menu_datasource.dart';
import 'package:smartmeal/data/mappers/menu_item_mapper.dart';
import 'package:smartmeal/core/errors/errors.dart';

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
