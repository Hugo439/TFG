import 'package:smartmeal/domain/entities/shopping_item.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItem>> getShoppingItems();
  Future<void> addShoppingItem(ShoppingItem item);
  Future<void> addShoppingItemsBatch(
    List<ShoppingItem> items,
  ); // Nuevo: escritura batch
  Future<void> updateShoppingItem(ShoppingItem item);
  Future<void> toggleItemChecked(String id, bool isChecked);
  Future<void> deleteShoppingItem(String itemId);
  Future<void> deleteCheckedItems(String userId);
  Future<double> getTotalPrice();
  Future<void> setAllChecked(bool checked);
  Future<void> clearLocalCache(); // Nuevo: limpiar caché local
}
