import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/shopping/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_checked_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/set_all_shopping_items_checked_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ShoppingStatus { idle, loading, loaded, error }

class ShoppingState {
  final ShoppingStatus status;
  final List<ShoppingItem> items;
  final double totalPrice;
  final String? error;

  const ShoppingState({
    this.status = ShoppingStatus.idle,
    this.items = const [],
    this.totalPrice = 0.0,
    this.error,
  });

  int get totalItems => items.length;
  int get checkedItems => items.where((item) => item.isChecked).length;
  
  List<ShoppingItem> get uncheckedItems => 
      items.where((item) => !item.isChecked).toList();

  ShoppingState copyWith({
    ShoppingStatus? status,
    List<ShoppingItem>? items,
    double? totalPrice,
    String? error,
  }) {
    return ShoppingState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      error: error,
    );
  }
}

class ShoppingViewModel extends ChangeNotifier {
  final GetShoppingItemsUseCase _getShoppingItems;
  final AddShoppingItemUseCase _addShoppingItem;
  final ToggleShoppingItemUseCase _toggleShoppingItem;
  final GetTotalPriceUseCase _getTotalPrice;
  final GenerateShoppingFromMenusUseCase _generateFromMenus;
  final DeleteCheckedShoppingItemsUseCase _deleteCheckedItems;
  final SetAllShoppingItemsCheckedUseCase _setAllChecked;
  final FirebaseAuth _auth;

  ShoppingViewModel(
    this._getShoppingItems,
    this._addShoppingItem,
    this._toggleShoppingItem,
    this._getTotalPrice,
    this._generateFromMenus,
    this._deleteCheckedItems,
    this._setAllChecked,
    this._auth,
  );

  ShoppingState _state = const ShoppingState();
  ShoppingState get state => _state;

  Future<void> loadShoppingItems() async {
    _update(_state.copyWith(status: ShoppingStatus.loading, error: null));
    
    try {
      final items = await _getShoppingItems(const NoParams());
      final total = await _getTotalPrice(const NoParams());
      
      _update(_state.copyWith(
        status: ShoppingStatus.loaded,
        items: items,
        totalPrice: total,
      ));
    } catch (e) {
      _update(_state.copyWith(
        status: ShoppingStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<bool> addItem(ShoppingItem item) async {
    try {
      await _addShoppingItem(item);
      await loadShoppingItems();
      return true;
    } catch (e) {
      _update(_state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> toggleItem(String id, bool isChecked) async {
    try {
      await _toggleShoppingItem(ToggleShoppingItemParams(
        id: id,
        isChecked: isChecked,
      ));
      await loadShoppingItems();
      return true;
    } catch (e) {
      _update(_state.copyWith(error: e.toString()));
      return false;
    }
  }



  Future<bool> generateFromMenus() async {
    _update(_state.copyWith(status: ShoppingStatus.loading, error: null));
    
    try {
      await _generateFromMenus(const NoParams());
      await loadShoppingItems();
      return true;
    } catch (e) {
      _update(_state.copyWith(
        status: ShoppingStatus.error,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Elimina todos los ítems marcados como comprados
  Future<void> deleteCheckedItems() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    try {
      await _deleteCheckedItems.call(currentUser.uid);
      // Recargar la lista
      await loadShoppingItems();
    } catch (e) {
      if (kDebugMode) {
        print('Error eliminando ítems marcados: $e');
      }
    }
  }

  Future<void> setAllChecked(bool checked) async {
    await _setAllChecked(checked);
    await loadShoppingItems();
  }

  void _update(ShoppingState s) {
    _state = s;
    notifyListeners();
  }
}