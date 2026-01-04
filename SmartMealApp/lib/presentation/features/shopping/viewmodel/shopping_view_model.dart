import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/errors/errors.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/shopping/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_checked_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/set_all_shopping_items_checked_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Estados de la pantalla de lista de compra.
enum ShoppingStatus { idle, loading, loaded, error, info }

/// Estado del ViewModel de lista de compra.
class ShoppingState {
  final ShoppingStatus status;
  final List<ShoppingItem> items;
  final double totalPrice;
  final String? error;
  final String? infoMessage;

  const ShoppingState({
    this.status = ShoppingStatus.loading,
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

/// ViewModel para lista de compra.
///
/// Responsabilidades:
/// - Cargar items de compra del usuario
/// - Generar lista desde menús activos
/// - Marcar items como comprados/pendientes
/// - Eliminar items comprados
/// - Calcular precio total
///
/// Funcionalidades principales:
/// 1. **loadShoppingItems()**: Carga items desde Firestore
/// 2. **generateFromMenus()**: Genera lista desde menús
/// 3. **toggleItem()**: Marca item como comprado/pendiente
/// 4. **deleteCheckedItems()**: Elimina todos los comprados
/// 5. **setAllChecked()**: Marca/desmarca todos
///
/// Optimistic UI:
/// - toggleItem y setAllChecked actualizan UI inmediatamente
/// - Si falla, revierte cambios automáticamente
///
/// Estados:
/// - **idle**: Sin actividad
/// - **loading**: Cargando/procesando
/// - **loaded**: Items cargados
/// - **error**: Error en operación
/// - **info**: Información al usuario (ej: menú ya generado)
///
/// Uso:
/// ```dart
/// final vm = Provider.of<ShoppingViewModel>(context);
/// await vm.loadShoppingItems();
/// await vm.generateFromMenus(context);
/// await vm.toggleItem(itemId, true);
/// ```
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

  /// Carga items de compra del usuario desde Firestore.
  ///
  /// Parámetros:
  /// - **preserveInfoMessage**: mantener mensaje informativo actual
  ///
  /// Flujo:
  /// 1. Llama a GetShoppingItemsUseCase
  /// 2. Llama a GetTotalPriceUseCase
  /// 3. Actualiza estado con items y total
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

  /// Marca/desmarca item como comprado con Optimistic UI.
  ///
  /// Parámetros:
  /// - **id**: ID del item
  /// - **isChecked**: true = comprado, false = pendiente
  ///
  /// Optimistic UI:
  /// 1. Actualiza UI inmediatamente
  /// 2. Llama a ToggleShoppingItemUseCase
  /// 3. Si falla, revierte cambios
  ///
  /// Retorna true si éxito, false si error.
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

  /// Genera lista de compra desde menús activos.
  ///
  /// Flujo:
  /// 1. Llama a GenerateShoppingFromMenusUseCase
  /// 2. UseCase agrega ingredientes de menús
  /// 3. Normaliza y agrega cantidades
  /// 4. Estima precios
  /// 5. Recarga items
  ///
  /// Casos especiales:
  /// - **MenuAlreadyGeneratedException**: menú ya pasado a compra
  ///   - Muestra mensaje informativo (no error)
  /// - **Otros errores**: muestra error
  ///
  /// Retorna true si éxito, false si ya generado o error.
  Future<bool> generateFromMenus(BuildContext context) async {
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
    } on MenuAlreadyGeneratedException {
      // Es un aviso, no un error: menú ya fue pasado
      // Usar mensaje localizado
      _update(
        _state.copyWith(
          status: ShoppingStatus.info,
          infoMessage: context.l10n.menuAlreadyGenerated,
        ),
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

  /// Elimina todos los items marcados como comprados.
  ///
  /// Optimistic UI:
  /// 1. Remueve items localmente
  /// 2. Llama a DeleteCheckedShoppingItemsUseCase
  /// 3. Si falla, revierte cambios
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

  /// Marca/desmarca todos los items.
  ///
  /// Parámetros:
  /// - **checked**: true = marcar todos, false = desmarcar todos
  ///
  /// Optimistic UI:
  /// 1. Actualiza todos los items localmente
  /// 2. Llama a SetAllShoppingItemsCheckedUseCase
  /// 3. Si falla, revierte cambios
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
