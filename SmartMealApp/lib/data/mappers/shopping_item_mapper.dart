import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';
import 'package:smartmeal/data/models/shopping_item_model.dart';

class ShoppingItemMapper {
  /// Convertir de Model (Firestore) a Entity (Dominio)
  static ShoppingItem fromModel(ShoppingItemModel model) {
    return ShoppingItem(
      id: model.id,
      name: ShoppingItemName(model.name),
      quantity: ShoppingItemQuantity(model.quantity),
      price: Price(model.price),
      category: model.category,
      usedInMenus: model.usedInMenus,
      isChecked: model.isChecked,
      createdAt: model.createdAt,
    );
  }

  /// Convertir de Entity (Dominio) a Model (Firestore)
  static ShoppingItemModel toModel(ShoppingItem item) {
    return ShoppingItemModel(
      id: item.id,
      name: item.name.value,
      quantity: item.quantity.value,
      price: item.price.value,
      category: item.category,
      usedInMenus: item.usedInMenus,
      isChecked: item.isChecked,
      createdAt: item.createdAt,
    );
  }
}