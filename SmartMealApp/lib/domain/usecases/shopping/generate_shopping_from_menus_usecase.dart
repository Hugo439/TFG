import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:flutter/foundation.dart';

class GenerateShoppingFromMenusUseCase implements UseCase<List<ShoppingItem>, NoParams> {
  final MenuRepository menuRepository;
  final ShoppingRepository shoppingRepository;
  final IngredientParser parser;
  final IngredientAggregator aggregator;
  final PriceCategoryHelper priceHelper;

  GenerateShoppingFromMenusUseCase({
    required this.menuRepository,
    required this.shoppingRepository,
    IngredientParser? parser,
    IngredientAggregator? aggregator,
    PriceCategoryHelper? priceHelper,
  })  : parser = parser ?? IngredientParser(),
        aggregator = aggregator ?? IngredientAggregator(),
        priceHelper = priceHelper ?? PriceCategoryHelper();

  @override
  Future<List<ShoppingItem>> call(NoParams params) async {
    if (kDebugMode) {
      print('🛒 [GenerateShoppingUseCase] Iniciando generación...');
    }

    // Obtener todos los menús
    final menus = await menuRepository.getMenuItems();
    
    if (kDebugMode) {
      print('🛒 [GenerateShoppingUseCase] Menús obtenidos: ${menus.length}');
      for (var menu in menus) {
        print('   - ${menu.name.value}: ${menu.ingredients.length} ingredientes');
        for (var ing in menu.ingredients) {
          print('      · $ing');
        }
      }
    }

    for (final menu in menus) {
      for (final ingredientStr in menu.ingredients) {
        final portion = parser.parse(ingredientStr);
        aggregator.addPortion(portion, menu.name.value);
        
        if (kDebugMode) {
          print('🛒 Parseado: "$ingredientStr" → ${portion.name} (${portion.quantityBase} ${portion.unitKind})');
        }
      }
    }

    final aggList = aggregator.toList();
    
    if (kDebugMode) {
      print('🛒 [GenerateShoppingUseCase] Ingredientes agregados: ${aggList.length}');
      for (var agg in aggList) {
        print('   - ${agg.name}: ${agg.quantityLabel} (usado en: ${agg.usedInMenus.join(", ")})');
      }
    }

    final List<ShoppingItem> shoppingItems = [];

    for (final agg in aggList) {
      final estimatedPrice = priceHelper.estimatePrice(agg.unitKind, agg.totalBase);
      final category = priceHelper.guessCategory(agg.name);

      try {
        final item = ShoppingItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + shoppingItems.length.toString(),
          name: ShoppingItemName(agg.name),
          quantity: ShoppingItemQuantity(agg.quantityLabel),
          price: Price(estimatedPrice),
          category: category,
          usedInMenus: agg.usedInMenus,
          isChecked: false,
          createdAt: DateTime.now(),
        );

        await shoppingRepository.addShoppingItem(item);
        shoppingItems.add(item);
        
        if (kDebugMode) {
          print('✅ Item creado: ${item.name.value} - ${item.quantity.value}');
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
  }
}