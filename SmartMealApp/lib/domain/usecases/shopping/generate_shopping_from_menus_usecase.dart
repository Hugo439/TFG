import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/errors/errors.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/cost_estimator.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';

/// Caso de uso para generar lista de compras desde el menú semanal.
///
/// Proceso complejo que involucra:
/// 1. **Extracción**: Obtener ingredientes de todas las recetas del menú
/// 2. **Parsing**: Extraer cantidad, unidad y nombre de cada ingrediente
/// 3. **Normalización**: Unificar variantes ("pollo pechuga", "pechuga pollo" → "pollo pechuga")
/// 4. **Agregación**: Sumar cantidades de ingredientes repetidos
/// 5. **Categorización**: Asignar categoría automáticamente
/// 6. **Estimación de precio**: Calcular precio aproximado
/// 7. **Persistencia**: Guardar en Firestore en batch
///
/// Servicios utilizados:
/// - **IngredientParser**: Parsea "200 g pollo" → (cantidad: 200, unidad: g, nombre: pollo)
/// - **SmartIngredientNormalizer**: Normaliza nombres para agrupar variantes
/// - **IngredientAggregator**: Suma cantidades del mismo ingrediente
/// - **SmartCategoryHelper**: Determina categoría automáticamente
/// - **CostEstimator**: Estima precio basado en cantidad y categoría
/// - **PriceEstimator**: Obtiene precio de base de datos/Firestore
///
/// Optimizaciones:
/// - Operación batch para guardar (una sola transacción)
/// - Logging detallado de rendimiento
/// - Tracking de errores en parsing
///
/// Returns: Lista de ShoppingItems creados.
///
/// Throws:
/// - [NotFoundFailure] si no hay menú generado
/// - [ServerFailure] si falla la persistencia
class GenerateShoppingFromMenusUseCase
    implements UseCase<List<ShoppingItem>, NoParams> {
  final MenuRepository menuRepository;
  final ShoppingRepository shoppingRepository;
  final IngredientParser parser;
  final IngredientAggregator aggregator;
  final PriceEstimator priceEstimator;
  final SmartCategoryHelper categoryHelper;
  final SmartIngredientNormalizer normalizer;
  final CostEstimator costEstimator;

  GenerateShoppingFromMenusUseCase({
    required this.menuRepository,
    required this.shoppingRepository,
    required this.parser,
    required this.aggregator,
    required this.priceEstimator,
    required this.categoryHelper,
    required this.normalizer,
    required this.costEstimator,
  });

  @override
  Future<List<ShoppingItem>> call(NoParams params) async {
    final startTime = DateTime.now();

    if (kDebugMode) {
      print(
        '🛒 [GenerateShoppingUseCase] Iniciando generación desde último menú...',
      );
    }

    try {
      final menus = await menuRepository.getLatestWeeklyMenu();

      if (menus.isEmpty) {
        if (kDebugMode) {
          print('⚠️ [GenerateShoppingUseCase] No hay menús disponibles');
        }
        return [];
      }

      // Evitar duplicar ingredientes de un mismo menú ya generado
      final menuNames = menus.map((m) => m.name.value).toSet();
      final existingItems = await shoppingRepository.getShoppingItems();
      final alreadyGenerated = existingItems.any(
        (item) => item.usedInMenus.any(menuNames.contains),
      );
      if (alreadyGenerated) {
        if (kDebugMode) {
          print(
            '⏭️ [GenerateShoppingUseCase] Menú ya está en la lista de compra; se omite generación',
          );
        }
        throw MenuAlreadyGeneratedException(
          message:
              'Los ingredientes de este menú ya se han añadido a la lista de compra',
        );
      }

      // 🗑️  LIMPIAR CACHÉ LOCAL antes de generar nueva lista
      await shoppingRepository.clearLocalCache();

      // Procesar ingredientes
      for (final menu in menus) {
        for (final ingredientStr in menu.ingredients) {
          final portion = parser.parse(ingredientStr);
          final normalizedName = normalizer.normalize(portion.name);
          if (normalizedName.isEmpty) continue;
          final normalizedPortion = portion.copyWith(name: normalizedName);
          aggregator.addPortion(normalizedPortion, menu.name.value);
        }
      }

      final aggList = aggregator.toList();

      // 📦 PRE-CACHEAR precios por categoría usando CostEstimator
      final preCacheStart = DateTime.now();
      await costEstimator.preloadCategoriesForAggregated(
        aggList,
        maxConcurrent: 6,
      );

      final preCacheDuration = DateTime.now().difference(preCacheStart);
      if (kDebugMode) {
        print(
          '✅ [GenerateShoppingUseCase] Caché de precios listo (${preCacheDuration.inMilliseconds}ms)',
        );
      }

      final List<ShoppingItem> shoppingItems = [];

      // 📦 Crear items con precios en lotes (batch size = 4 para mejor concurrencia)
      final estimationStart = DateTime.now();
      const batchSize = 4;
      for (int i = 0; i < aggList.length; i += batchSize) {
        final chunk = aggList.sublist(
          i,
          i + batchSize > aggList.length ? aggList.length : i + batchSize,
        );

        final futures = chunk.map((agg) async {
          final category = categoryHelper.guessCategory(agg.name);

          final estimatedPrice = await priceEstimator.estimatePrice(
            ingredientName: agg.name,
            category: category.firestoreKey,
            kind: agg.unitKind,
            base: agg.totalBase,
          );

          try {
            final item = ShoppingItem(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  agg.name.hashCode.toString(),
              name: ShoppingItemName(agg.name),
              quantity: ShoppingItemQuantity(agg.quantityLabel),
              price: Price(estimatedPrice),
              category: category.displayName,
              usedInMenus: agg.usedInMenus,
              isChecked: false,
              createdAt: DateTime.now(),
            );

            if (kDebugMode) {
              print(
                '✅ Item: ${item.name.value} - ${item.quantity.value} - €${estimatedPrice.toStringAsFixed(2)} [${category.displayName}]',
              );
            }
            return item;
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error creando item ${agg.name}: $e');
            }
            return null;
          }
        }).toList();

        final results = await Future.wait(futures);
        shoppingItems.addAll(results.whereType<ShoppingItem>());
      }

      final estimationDuration = DateTime.now().difference(estimationStart);
      if (kDebugMode) {
        print(
          '✅ [GenerateShoppingUseCase] Estimación completada (${estimationDuration.inMilliseconds}ms)',
        );
      }

      // 📦 Guardar todos los items en una sola transacción (batch write)
      final writeStart = DateTime.now();
      if (shoppingItems.isNotEmpty) {
        await shoppingRepository.addShoppingItemsBatch(shoppingItems);
      }

      final writeDuration = DateTime.now().difference(writeStart);
      if (kDebugMode) {
        print(
          '✅ [GenerateShoppingUseCase] Batch write completado (${writeDuration.inMilliseconds}ms)',
        );
      }

      final totalDuration = DateTime.now().difference(startTime);
      if (kDebugMode) {
        print('🛒 [GenerateShoppingUseCase] ✅ COMPLETADO');
        print('   └─ Total items: ${shoppingItems.length}');
        print('   └─ Pre-caché: ${preCacheDuration.inMilliseconds}ms');
        print('   └─ Estimación: ${estimationDuration.inMilliseconds}ms');
        print('   └─ Escritura: ${writeDuration.inMilliseconds}ms');
        print(
          '   └─ ⏱️  TIEMPO TOTAL: ${totalDuration.inSeconds}s ${totalDuration.inMilliseconds % 1000}ms',
        );
      }

      return shoppingItems;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GenerateShoppingUseCase] Error: $e');
      }
      rethrow;
    }
  }
}
