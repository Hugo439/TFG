import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/repositories/statistics_repository.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/data/datasources/remote/shopping_datasource.dart';
import 'package:smartmeal/data/datasources/remote/user_price_override_firestore_datasource.dart';
import 'package:smartmeal/data/datasources/local/shopping_local_datasource.dart';
import 'package:smartmeal/data/mappers/shopping_item_mapper.dart';
import 'package:smartmeal/domain/value_objects/price.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/data/utils/shopping_repository_impl_helper.dart';
import 'package:smartmeal/data/datasources/local/statistics_cache_invalidator.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final ShoppingDataSource dataSource;
  final UserPriceFirestoreDatasource userPriceDatasource;
  final ShoppingLocalDatasource localDatasource;
  final FirebaseAuth auth;
  final SmartIngredientNormalizer _normalizer = SmartIngredientNormalizer();
  final IngredientParser _parser = IngredientParser();
  final StatisticsRepository Function() _getStatisticsRepository;

  ShoppingRepositoryImpl({
    required this.dataSource,
    required this.userPriceDatasource,
    required this.localDatasource,
    required StatisticsRepository Function() getStatisticsRepository,
    required this.auth,
  }) : _getStatisticsRepository = getStatisticsRepository;

  StatisticsRepository get statisticsRepository => _getStatisticsRepository();

  @override
  Future<List<ShoppingItem>> getShoppingItems() async {
    final startTime = DateTime.now();

    // 1️⃣  Intentar cargar del caché local primero
    try {
      final cachedModels = await localDatasource.getCachedShoppingItems();
      if (cachedModels != null && cachedModels.isNotEmpty) {
        final cachedItems = cachedModels
            .map((model) => ShoppingItemMapper.fromModel(model))
            .toList();

        final totalDuration = DateTime.now().difference(startTime);
        if (kDebugMode) {
          print('📦 [ShoppingRepository] getShoppingItems (desde CACHÉ)');
          print('   └─ Items cargados: ${cachedItems.length}');
          print('   └─ ⏱️  TIEMPO TOTAL: ${totalDuration.inMilliseconds}ms');
        }
        return cachedItems;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [ShoppingRepository] Error al cargar caché: $e');
      }
    }

    // 2️⃣  Si no hay caché, cargar desde Firestore
    final models = await dataSource.getShoppingItems();
    final items = models
        .map((model) => ShoppingItemMapper.fromModel(model))
        .toList();

    // Aplicar precios personalizados del usuario (fetch único + O(1) lookups)
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      // Cargar todos los overrides del usuario de una sola vez
      try {
        final overridesStart = DateTime.now();
        final overrides = await userPriceDatasource.getAllUserOverrides(userId);
        final overridesDuration = DateTime.now().difference(overridesStart);

        final priceByIngredientId = {
          for (final o in overrides)
            o.ingredientId.toLowerCase(): o.customPrice,
        };

        final itemsWithCustomPrices = items.map((item) {
          final normalizedName = _normalizer
              .normalize(item.nameValue)
              .toLowerCase();
          final customPricePerUnit = priceByIngredientId[normalizedName];
          if (customPricePerUnit != null) {
            // Parsear la cantidad para calcular el precio total
            final portion = _parser.parse(
              '${item.quantityValue} ${item.nameValue}',
            );
            final totalPrice = calculatePriceWithQuantity(
              pricePerUnit: customPricePerUnit,
              quantityBase: portion.quantityBase,
              unitKind: portion.unitKind,
              ingredientName: normalizedName,
            );
            return item.copyWith(price: Price(totalPrice));
          }
          return item;
        }).toList();

        // Orden alfabético A→Z por nombre visible
        itemsWithCustomPrices.sort(
          (a, b) => a.nameValue.compareTo(b.nameValue),
        );

        // 3️⃣  Guardar en caché local para próxima carga
        final modelsToCache = itemsWithCustomPrices
            .map((item) => ShoppingItemMapper.toModel(item))
            .toList();
        await localDatasource.cacheShoppingItems(modelsToCache);

        final totalDuration = DateTime.now().difference(startTime);
        if (kDebugMode) {
          print(
            '📦 [ShoppingRepository] getShoppingItems completado (desde FIRESTORE)',
          );
          print('   └─ Items cargados: ${items.length}');
          print('   └─ Overrides aplicados: ${overrides.length}');
          print('   └─ Carga overrides: ${overridesDuration.inMilliseconds}ms');
          print('   └─ ⏱️  TIEMPO TOTAL: ${totalDuration.inMilliseconds}ms');
        }

        return itemsWithCustomPrices;
      } catch (_) {
        // En caso de error, devolver items originales ordenados alfabéticamente
        items.sort((a, b) => a.nameValue.compareTo(b.nameValue));
        final totalDuration = DateTime.now().difference(startTime);
        if (kDebugMode) {
          print(
            '⚠️ [ShoppingRepository] Error en overrides; devolviendo items sin customización',
          );
          print('   └─ ⏱️  TIEMPO: ${totalDuration.inMilliseconds}ms');
        }
        return items;
      }
    }

    // Sin usuario: devolver ordenado alfabéticamente
    items.sort((a, b) => a.nameValue.compareTo(b.nameValue));

    // 3️⃣  Guardar en caché local
    final modelsToCache = items
        .map((item) => ShoppingItemMapper.toModel(item))
        .toList();
    await localDatasource.cacheShoppingItems(modelsToCache);

    final totalDuration = DateTime.now().difference(startTime);
    if (kDebugMode) {
      print(
        '📦 [ShoppingRepository] getShoppingItems (sin usuario customización)',
      );
      print('   └─ Items: ${items.length}');
      print('   └─ ⏱️  TIEMPO: ${totalDuration.inMilliseconds}ms');
    }
    return items;
  }

  @override
  Future<void> addShoppingItem(ShoppingItem item) async {
    final model = ShoppingItemMapper.toModel(item);
    await dataSource.addShoppingItem(item.id, model.toFirestoreCreate());
    // Invalida caché porque se añadió un nuevo item
    await localDatasource.clearCache();
    await _invalidateStatisticsCache();
    await StatisticsCacheInvalidator.clearLocalStatisticsCache();
  }

  @override
  Future<void> addShoppingItemsBatch(List<ShoppingItem> items) async {
    if (items.isEmpty) return;
    final models = items
        .map(
          (item) =>
              ShoppingItemMapper.toModel(item).toFirestoreCreate()
                ..['id'] = item.id,
        )
        .toList();
    await dataSource.addShoppingItemsBatch(models);
    // Invalida caché porque se añadieron items en batch
    await localDatasource.clearCache();
    await _invalidateStatisticsCache();
    await StatisticsCacheInvalidator.clearLocalStatisticsCache();
  }

  @override
  Future<void> updateShoppingItem(ShoppingItem item) async {
    final model = ShoppingItemMapper.toModel(item);
    await dataSource.updateShoppingItem(item.id, model.toFirestore());
    // Invalida caché porque el item cambió
    await localDatasource.clearCache();
    await _invalidateStatisticsCache();
    await StatisticsCacheInvalidator.clearLocalStatisticsCache();
  }

  @override
  Future<void> toggleItemChecked(String id, bool isChecked) async {
    await dataSource.updateShoppingItem(id, {'isChecked': isChecked});
    // Invalida caché porque el estado checked cambió
    await localDatasource.clearCache();
  }

  @override
  Future<void> deleteShoppingItem(String itemId) async {
    await dataSource.deleteShoppingItem(itemId);
    // Invalida caché porque se eliminó un item
    await localDatasource.clearCache();
    await _invalidateStatisticsCache();
    await StatisticsCacheInvalidator.clearLocalStatisticsCache();
  }

  @override
  Future<double> getTotalPrice() async {
    final items = await getShoppingItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.priceValue);
  }

  @override
  Future<void> deleteCheckedItems(String userId) async {
    await dataSource.deleteCheckedItems(userId);
    // Invalida caché porque se eliminaron items
    await localDatasource.clearCache();
    await _invalidateStatisticsCache();
    await StatisticsCacheInvalidator.clearLocalStatisticsCache();
  }

  @override
  Future<void> setAllChecked(bool checked) async {
    await dataSource.setAllChecked(checked);
    // Invalida caché porque todos los items cambiaron
    await localDatasource.clearCache();
    await _invalidateStatisticsCache();
    await StatisticsCacheInvalidator.clearLocalStatisticsCache();
  }

  @override
  Future<void> clearLocalCache() async {
    await localDatasource.clearCache();
  }

  /// Invalida el caché de estadísticas cuando cambia algo en shopping
  /// (porque el coste estimado se recalcula basándose en items)
  Future<void> _invalidateStatisticsCache() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId != null) {
        await statisticsRepository.clearStatisticsCache(userId);
      }
    } catch (_) {
      // Fallar silenciosamente, no debería bloquear operación
    }
  }
}
