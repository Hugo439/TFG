import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';

class AddShoppingItemViewModel extends ChangeNotifier {
  final AddShoppingItemUseCase _addShoppingItem;
  final ShoppingItem? itemToEdit;

  String _name = '';
  String _quantity = '';
  String _price = '';
  String _category = 'Frutas y Verduras ';
  String _usedInMenus = '';
  bool _loading = false;
  String? _error;

  String get name => _name;
  String get quantity => _quantity;
  String get price => _price;
  String get category => _category;
  String get usedInMenus => _usedInMenus;
  bool get loading => _loading;
  String? get error => _error;

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
    _error = null;
    notifyListeners();
  }

  void setQuantity(String value) {
    _quantity = value;
    _error = null;
    notifyListeners();
  }

  void setPrice(String value) {
    _price = value;
    _error = null;
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

  Future<bool> save() async {
    if (_name.trim().isEmpty || _quantity.trim().isEmpty || _price.trim().isEmpty) {
      _error = 'Por favor completa todos los campos obligatorios';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
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
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al guardar el producto';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}