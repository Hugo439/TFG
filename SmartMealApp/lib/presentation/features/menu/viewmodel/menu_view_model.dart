import 'package:flutter/material.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';

enum MenuState { initial, loading, loaded, error }

class MenuViewModel extends ChangeNotifier {
  final WeeklyMenuRepository _weeklyMenuRepository = sl<WeeklyMenuRepository>();

  MenuState _state = MenuState.initial;
  MenuState get state => _state;

  List<WeeklyMenu> _menus = [];
  List<WeeklyMenu> get menus => _menus;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadWeeklyMenus(String userId) async {
    print('Buscando menús para userId: $userId');
    _state = MenuState.loading;
    safeNotifyListeners();
    try {
      final result = await _weeklyMenuRepository.getWeeklyMenus(userId);
      print('Menús encontrados: ${result.length}');
      _menus = result;
      _state = MenuState.loaded;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = MenuState.error;
      safeNotifyListeners();
    }
  }
}