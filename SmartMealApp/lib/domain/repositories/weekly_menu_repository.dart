import 'package:smartmeal/domain/entities/weekly_menu.dart';

abstract class WeeklyMenuRepository {
  Future<List<WeeklyMenu>> getUserMenus(String userId);
  Future<WeeklyMenu> getMenuById(String id);
  Future<void> saveMenu(WeeklyMenu menu);
  Future<void> updateMenu(WeeklyMenu menu);
  Future<void> deleteMenu(String id);
  Future<WeeklyMenu?> getCurrentWeekMenu(String userId);
  Future<List<WeeklyMenu>> getWeeklyMenus(String userId);
}