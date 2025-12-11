import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/data/datasources/remote/shopping_datasource.dart';
import 'package:smartmeal/data/datasources/remote/user_price_firestore_datasource.dart';
import 'package:smartmeal/data/mappers/shopping_item_mapper.dart';
import 'package:smartmeal/domain/value_objects/price.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final ShoppingDataSource dataSource;
  final UserPriceFirestoreDatasource userPriceDatasource;
  final FirebaseAuth auth;
  final SmartIngredientNormalizer _normalizer = SmartIngredientNormalizer();

  ShoppingRepositoryImpl({
    required this.dataSource,
    required this.userPriceDatasource,
    required this.auth,
  });

  @override
  Future<List<ShoppingItem>> getShoppingItems() async {
    final models = await dataSource.getShoppingItems();
    final items = models.map((model) => ShoppingItemMapper.fromModel(model)).toList();
    
    // Aplicar precios personalizados del usuario
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      final itemsWithCustomPrices = <ShoppingItem>[];
      
      for (final item in items) {
        try {
          // Normalizar el nombre del ingrediente
          final normalizedName = _normalizer.normalize(item.nameValue);
          
          // Buscar precio personalizado
          final override = await userPriceDatasource.getUserPriceOverride(
            userId: userId,
            ingredientId: normalizedName,
          );
          
          if (override != null) {
            // Aplicar precio personalizado
            itemsWithCustomPrices.add(item.copyWith(
              price: Price(override.customPrice),
            ));
          } else {
            // Mantener precio original
            itemsWithCustomPrices.add(item);
          }
        } catch (e) {
          // Si falla, mantener precio original
          itemsWithCustomPrices.add(item);
        }
      }
      
      return itemsWithCustomPrices;
    }
    
    return items;
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