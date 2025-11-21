import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItemMapper {
  static ShoppingItem fromFirestore(Map<String, dynamic> data) {
    return ShoppingItem(
      id: data['id'] ?? '',
      name: ShoppingItemName(data['name'] ?? ''),
      quantity: ShoppingItemQuantity(data['quantity'] ?? ''),
      price: Price(data['price']?.toDouble() ?? 0.0),
      category: data['category'] ?? 'Supermercado',
      usedInMenus: List<String>.from(data['usedInMenus'] ?? []),
      isChecked: data['isChecked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(ShoppingItem item) {
    return {
      'name': item.name.value,
      'quantity': item.quantity.value,
      'price': item.price.value,
      'category': item.category,
      'usedInMenus': item.usedInMenus,
      'isChecked': item.isChecked,
    };
  }

  static Map<String, dynamic> toFirestoreCreate(ShoppingItem item) {
    return {
      ...toFirestore(item),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}