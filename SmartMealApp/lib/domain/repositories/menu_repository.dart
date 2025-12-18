import 'package:smartmeal/domain/entities/menu_item.dart';

abstract class MenuRepository {
  Future<List<MenuItem>> getMenuItems();
  Future<List<MenuItem>> getRecommendedMenuItems(int limit);
  Future<MenuItem> getMenuItem(String id);
  Future<void> createMenuItem(MenuItem menuItem);
  Future<void> updateMenuItem(MenuItem menuItem);
  Future<void> deleteMenuItem(String id);
  Future<List<MenuItem>> getLatestWeeklyMenu();
}
