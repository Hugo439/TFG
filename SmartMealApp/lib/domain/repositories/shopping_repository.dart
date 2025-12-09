import 'package:smartmeal/domain/entities/shopping_item.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItem>> getShoppingItems();
  Future<void> addShoppingItem(ShoppingItem item);
  Future<void> updateShoppingItem(ShoppingItem item);
  Future<void> toggleItemChecked(String id, bool isChecked);
  Future<void> deleteShoppingItem(String itemId);
  Future<void> deleteCheckedItems(String userId);
  Future<double> getTotalPrice();
}