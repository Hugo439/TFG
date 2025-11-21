import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';

class ShoppingItem {
  final String id;
  final ShoppingItemName name;
  final ShoppingItemQuantity quantity;
  final Price price;
  final String category; // Supermercado, Frutería, Carnicería, Quesería
  final List<String> usedInMenus; // Para qué menús se necesita
  final bool isChecked;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.usedInMenus,
    this.isChecked = false,
    required this.createdAt,
  });

  // Helper getters
  String get nameValue => name.value;
  String get quantityValue => quantity.value;
  double get priceValue => price.value;

  ShoppingItem copyWith({
    String? id,
    ShoppingItemName? name,
    ShoppingItemQuantity? quantity,
    Price? price,
    String? category,
    List<String>? usedInMenus,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      usedInMenus: usedInMenus ?? this.usedInMenus,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}