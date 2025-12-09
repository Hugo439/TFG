import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/data/datasources/remote/shopping_datasource.dart';
import 'package:smartmeal/data/mappers/shopping_item_mapper.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final ShoppingDataSource dataSource;

  ShoppingRepositoryImpl({required this.dataSource});

  @override
  Future<List<ShoppingItem>> getShoppingItems() async {
    final models = await dataSource.getShoppingItems();
    return models.map((model) => ShoppingItemMapper.fromModel(model)).toList();
  }

  @override
  Future<void> addShoppingItem(ShoppingItem item) async {
    final model = ShoppingItemMapper.toModel(item);
    await dataSource.addShoppingItem(item.id, model.toFirestoreCreate());
  }

  @override
  Future<void> updateShoppingItem(ShoppingItem item) async {
    final model = ShoppingItemMapper.toModel(item);
    await dataSource.updateShoppingItem(item.id, model.toFirestore());
  }

  @override
  Future<void> toggleItemChecked(String id, bool isChecked) async {
    await dataSource.updateShoppingItem(id, {'isChecked': isChecked});
  }

  @override
  Future<void> deleteShoppingItem(String itemId) async {
    await dataSource.deleteShoppingItem(itemId);
  }

  @override
  Future<double> getTotalPrice() async {
    final items = await getShoppingItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.priceValue);
  }

  @override
  Future<void> deleteCheckedItems(String userId) {
    return dataSource.deleteCheckedItems(userId);
  }

  @override
  Future<void> setAllChecked(bool checked) {
    return dataSource.setAllChecked(checked);
  }
}