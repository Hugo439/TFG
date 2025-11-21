import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/data/datasources/remote/shopping_datasource.dart';
import 'package:smartmeal/data/mappers/shopping_item_mapper.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final ShoppingDataSource _dataSource;

  ShoppingRepositoryImpl({required ShoppingDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<ShoppingItem>> getShoppingItems() async {
    final data = await _dataSource.getShoppingItems();
    return data.map((item) => ShoppingItemMapper.fromFirestore(item)).toList();
  }

  @override
  Future<void> addShoppingItem(ShoppingItem item) async {
    await _dataSource.addShoppingItem(
      item.id,
      ShoppingItemMapper.toFirestoreCreate(item),
    );
  }

  @override
  Future<void> updateShoppingItem(ShoppingItem item) async {
    await _dataSource.updateShoppingItem(
      item.id,
      ShoppingItemMapper.toFirestore(item),
    );
  }

  @override
  Future<void> toggleItemChecked(String id, bool isChecked) async {
    await _dataSource.updateShoppingItem(id, {'isChecked': isChecked});
  }

  @override
  Future<void> deleteShoppingItem(String id) async {
    await _dataSource.deleteShoppingItem(id);
  }

  @override
  Future<void> clearCheckedItems() async {
    await _dataSource.clearCheckedItems();
  }

  @override
  Future<double> getTotalPrice() async {
    final items = await getShoppingItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.priceValue);
  }
}