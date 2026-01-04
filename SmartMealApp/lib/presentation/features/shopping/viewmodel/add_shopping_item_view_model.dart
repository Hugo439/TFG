import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';

/// Códigos de error al añadir/editar item de compra.
enum ShoppingErrorCode { requiredFields, saveError }

/// ViewModel para añadir/editar item de compra.
///
/// Responsabilidades:
/// - Gestionar formulario de item de compra
/// - Validar campos requeridos
/// - Crear ShoppingItem con Value Objects
/// - Guardar en Firestore
///
/// Modos:
/// 1. **Añadir**: itemToEdit == null
///    - Campos vacíos
///    - Crea nuevo item
///
/// 2. **Editar**: itemToEdit != null
///    - Campos precargados
///    - Actualiza item existente
///
/// Validaciones:
/// - name, quantity, price requeridos
/// - price debe ser número válido
/// - Value Objects validan formato
///
/// Uso:
/// ```dart
/// // Añadir
/// final vm = AddShoppingItemViewModel(addUseCase, null);
/// vm.setName('Pollo');
/// vm.setQuantity('500 g');
/// vm.setPrice('4.0');
/// await vm.save();
///
/// // Editar
/// final vm = AddShoppingItemViewModel(addUseCase, existingItem);
/// vm.setPrice('4.5'); // Solo cambia precio
/// await vm.save();
/// ```
class AddShoppingItemViewModel extends ChangeNotifier {
  final AddShoppingItemUseCase _addShoppingItem;
  final ShoppingItem? itemToEdit;

  String _name = '';
  String _quantity = '';
  String _price = '';
  String _category = 'Frutas y Verduras';
  String _usedInMenus = '';
  bool _loading = false;
  ShoppingErrorCode? _errorCode;
  String? _errorDetails;

  String get name => _name;
  String get quantity => _quantity;
  String get price => _price;
  String get category => _category;
  String get usedInMenus => _usedInMenus;
  bool get loading => _loading;
  ShoppingErrorCode? get errorCode => _errorCode;
  String? get errorDetails => _errorDetails;

  AddShoppingItemViewModel(this._addShoppingItem, this.itemToEdit) {
    if (itemToEdit != null) {
      _name = itemToEdit!.name.value;
      _quantity = itemToEdit!.quantity.value;
      _price = itemToEdit!.price.value.toString();
      _category = itemToEdit!.category;
      _usedInMenus = itemToEdit!.usedInMenus.join(', ');
    }
  }

  void setName(String value) {
    _name = value;
    _errorCode = null;
    _errorDetails = null;
    notifyListeners();
  }

  void setQuantity(String value) {
    _quantity = value;
    _errorCode = null;
    _errorDetails = null;
    notifyListeners();
  }

  void setPrice(String value) {
    _price = value;
    _errorCode = null;
    _errorDetails = null;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void setUsedInMenus(String value) {
    _usedInMenus = value;
    notifyListeners();
  }

  /// Guarda item de compra en Firestore.
  ///
  /// Validaciones:
  /// 1. name, quantity, price no vacíos
  /// 2. Crea Value Objects:
  ///    - ShoppingItemName(name)
  ///    - ShoppingItemQuantity(quantity)
  ///    - Price.fromString(price)
  /// 3. Parsea usedInMenus (separados por comas)
  ///
  /// Flujo:
  /// - Si itemToEdit != null: actualiza item existente
  /// - Si itemToEdit == null: crea nuevo item
  ///
  /// Errores:
  /// - ShoppingErrorCode.requiredFields: campos vacíos
  /// - ArgumentError: formato inválido (capturado en errorDetails)
  /// - ShoppingErrorCode.saveError: error al guardar
  ///
  /// Retorna true si éxito, false si error.
  Future<bool> save() async {
    if (_name.trim().isEmpty ||
        _quantity.trim().isEmpty ||
        _price.trim().isEmpty) {
      _errorCode = ShoppingErrorCode.requiredFields;
      notifyListeners();
      return false;
    }

    _loading = true;
    _errorCode = null;
    _errorDetails = null;
    notifyListeners();

    try {
      final nameVO = ShoppingItemName(_name.trim());
      final quantityVO = ShoppingItemQuantity(_quantity.trim());
      final priceVO = Price.fromString(_price.trim());

      final usedInMenusList = _usedInMenus.trim().isEmpty
          ? <String>[]
          : _usedInMenus
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

      final item = ShoppingItem(
        id: itemToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameVO,
        quantity: quantityVO,
        price: priceVO,
        category: _category,
        usedInMenus: usedInMenusList,
        isChecked: itemToEdit?.isChecked ?? false,
        createdAt: itemToEdit?.createdAt ?? DateTime.now(),
      );

      await _addShoppingItem(item);

      _loading = false;
      notifyListeners();
      return true;
    } on ArgumentError catch (e) {
      _errorDetails = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorCode = ShoppingErrorCode.saveError;
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
