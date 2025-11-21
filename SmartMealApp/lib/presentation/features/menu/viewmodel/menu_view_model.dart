import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/domain/usecases/get_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/get_recommended_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_menu_item_usecase.dart';

enum MenuStatus { idle, loading, loaded, error }

class MenuState {
  final MenuStatus status;
  final List<MenuItem> menuItems;
  final List<MenuItem> recommendedItems;
  final String? error;

  const MenuState({
    this.status = MenuStatus.idle,
    this.menuItems = const [],
    this.recommendedItems = const [],
    this.error,
  });

  MenuState copyWith({
    MenuStatus? status,
    List<MenuItem>? menuItems,
    List<MenuItem>? recommendedItems,
    String? error,
  }) {
    return MenuState(
      status: status ?? this.status,
      menuItems: menuItems ?? this.menuItems,
      recommendedItems: recommendedItems ?? this.recommendedItems,
      error: error,
    );
  }
}

class MenuViewModel extends ChangeNotifier {
  final GetMenuItemsUseCase _getMenuItems;
  final GetRecommendedMenuItemsUseCase _getRecommendedMenuItems;
  final DeleteMenuItemUseCase _deleteMenuItem;

  MenuState _state = const MenuState();
  MenuState get state => _state;

  MenuViewModel(
    this._getMenuItems,
    this._getRecommendedMenuItems,
    this._deleteMenuItem,
  );

  Future<void> loadMenuItems() async {
    _update(_state.copyWith(status: MenuStatus.loading, error: null));
    
    try {
      final menuItems = await _getMenuItems(const NoParams());
      final recommendedItems = await _getRecommendedMenuItems(
        const GetRecommendedMenuItemsParams(limit: 3),
      );
      
      _update(_state.copyWith(
        status: MenuStatus.loaded,
        menuItems: menuItems,
        recommendedItems: recommendedItems,
      ));
    } catch (e) {
      _update(_state.copyWith(
        status: MenuStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<bool> deleteMenuItem(String id) async {
    try {
      await _deleteMenuItem(id);
      await loadMenuItems(); // Recargar lista
      return true;
    } catch (e) {
      _update(_state.copyWith(error: e.toString()));
      return false;
    }
  }

  void _update(MenuState s) {
    _state = s;
    notifyListeners();
  }
}