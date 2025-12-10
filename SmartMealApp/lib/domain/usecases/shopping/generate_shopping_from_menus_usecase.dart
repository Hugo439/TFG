import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';

class GenerateShoppingFromMenusUseCase implements UseCase<List<ShoppingItem>, NoParams> {
  final MenuRepository menuRepository;
  final ShoppingRepository shoppingRepository;
  final IngredientParser parser;
  final IngredientAggregator aggregator;
  final PriceEstimator priceEstimator;
  final SmartCategoryHelper categoryHelper;
  final SmartIngredientNormalizer normalizer;

  GenerateShoppingFromMenusUseCase({
    required this.menuRepository,
    required this.shoppingRepository,
    required this.parser,
    required this.aggregator,
    required this.priceEstimator,
    required this.categoryHelper,
    required this.normalizer,
  });

  @override
  Future<List<ShoppingItem>> call(NoParams params) async {
    if (kDebugMode) {
      print('🛒 [GenerateShoppingUseCase] Iniciando generación desde último menú...');
    }

    try {
      final menus = await menuRepository.getLatestWeeklyMenu();
      
      if (menus.isEmpty) {
        if (kDebugMode) {
          print('⚠️ [GenerateShoppingUseCase] No hay menús disponibles');
        }
        return [];
      }

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

      final List<ShoppingItem> shoppingItems = [];

      // Crear items con precios
      for (final agg in aggList) {
        final category = categoryHelper.guessCategory(agg.name);
        
        // ✅ Usar firestoreKey en lugar de displayName
        final estimatedPrice = await priceEstimator.estimatePrice(
          ingredientName: agg.name,
          category: category.firestoreKey,  // 👈 CAMBIO
          kind: agg.unitKind,
          base: agg.totalBase,
        );

        try {
          final item = ShoppingItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                shoppingItems.length.toString(),
            name: ShoppingItemName(agg.name),
            quantity: ShoppingItemQuantity(agg.quantityLabel),
            price: Price(estimatedPrice),
            category: category.displayName,
            usedInMenus: agg.usedInMenus,
            isChecked: false,
            createdAt: DateTime.now(),
          );

          await shoppingRepository.addShoppingItem(item);
          shoppingItems.add(item);
          
          if (kDebugMode) {
            print('✅ Item: ${item.name.value} - ${item.quantity.value} - €${estimatedPrice.toStringAsFixed(2)} [${category.displayName}]');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error creando item ${agg.name}: $e');
          }
          continue;
        }
      }

      if (kDebugMode) {
        print('🛒 [GenerateShoppingUseCase] Total items añadidos: ${shoppingItems.length}');
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