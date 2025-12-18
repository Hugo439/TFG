import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/exceptions/menu_already_generated_exception.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/shopping/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_checked_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/set_all_shopping_items_checked_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ShoppingStatus { idle, loading, loaded, error, info }

class ShoppingState {
  final ShoppingStatus status;
  final List<ShoppingItem> items;
  final double totalPrice;
  final String? error;
  final String? infoMessage;

  const ShoppingState({
    this.status = ShoppingStatus.idle,
    this.items = const [],
    this.totalPrice = 0.0,
    this.error,
    this.infoMessage,
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
    String? infoMessage,
  }) {
    return ShoppingState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      error: error,
      infoMessage: infoMessage,
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

  Future<void> loadShoppingItems({bool preserveInfoMessage = false}) async {
    _update(
      _state.copyWith(
        status: ShoppingStatus.loading,
        error: null,
        infoMessage: preserveInfoMessage ? _state.infoMessage : null,
      ),
    );

    try {
      final items = await _getShoppingItems(const NoParams());
      final total = await _getTotalPrice(const NoParams());

      _update(
        _state.copyWith(
          status: ShoppingStatus.loaded,
          items: items,
          totalPrice: total,
          infoMessage: preserveInfoMessage ? _state.infoMessage : null,
        ),
      );
    } catch (e) {
      _update(
        _state.copyWith(status: ShoppingStatus.error, error: e.toString()),
      );
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
    // Optimistic UI: actualizar localmente sin recargar toda la lista
    final previousState = _state;
    final updatedItems = _state.items
        .map(
          (item) => item.id == id ? item.copyWith(isChecked: isChecked) : item,
        )
        .toList();

    _update(
      _state.copyWith(
        items: updatedItems,
        totalPrice: _calculateTotal(updatedItems),
      ),
    );

    try {
      await _toggleShoppingItem(
        ToggleShoppingItemParams(id: id, isChecked: isChecked),
      );
      return true;
    } catch (e) {
      // Revertir si falla
      _update(previousState.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> generateFromMenus() async {
    _update(
      _state.copyWith(
        status: ShoppingStatus.loading,
        error: null,
        infoMessage: null,
      ),
    );

    try {
      await _generateFromMenus(const NoParams());
      await loadShoppingItems();
      return true;
    } on MenuAlreadyGeneratedException catch (e) {
      // Es un aviso, no un error: menú ya fue pasado
      // No recargamos items (ya están), solo establecemos el mensaje
      _update(
        _state.copyWith(status: ShoppingStatus.loaded, infoMessage: e.message),
      );
      return false;
    } catch (e) {
      // Error real
      _update(
        _state.copyWith(status: ShoppingStatus.error, error: e.toString()),
      );
      return false;
    }
  }

  /// Elimina todos los ítems marcados como comprados
  Future<void> deleteCheckedItems() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final previousState = _state;

    try {
      // Optimistic: remover localmente y notificar
      final remaining = _state.items.where((item) => !item.isChecked).toList();
      _update(
        _state.copyWith(
          items: remaining,
          totalPrice: _calculateTotal(remaining),
        ),
      );

      await _deleteCheckedItems.call(currentUser.uid);
    } catch (e) {
      // Revertir en caso de error
      _update(previousState.copyWith(error: e.toString()));
      if (kDebugMode) {
        print('Error eliminando ítems marcados: $e');
      }
    }
  }

  Future<void> setAllChecked(bool checked) async {
    // Optimistic: marcar/desmarcar localmente
    final previousState = _state;
    final updated = _state.items
        .map((item) => item.copyWith(isChecked: checked))
        .toList();
    _update(
      _state.copyWith(items: updated, totalPrice: _calculateTotal(updated)),
    );

    try {
      await _setAllChecked(checked);
    } catch (e) {
      // Revertir si falla
      _update(previousState.copyWith(error: e.toString()));
    }
  }

  double _calculateTotal(List<ShoppingItem> items) {
    return items.fold<double>(0.0, (sum, item) => sum + item.priceValue);
  }

  void clearInfoMessage() {
    _update(_state.copyWith(infoMessage: null));
  }

  void _update(ShoppingState s) {
    _state = s;
    notifyListeners();
  }
}
