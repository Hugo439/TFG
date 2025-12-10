import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/category_helper.dart';
import 'package:flutter/foundation.dart';

class GenerateShoppingFromMenusUseCase implements UseCase<List<ShoppingItem>, NoParams> {
  final MenuRepository menuRepository;
  final ShoppingRepository shoppingRepository;
  final IngredientParser parser;
  final IngredientAggregator aggregator;
  final PriceEstimator priceEstimator;
  final CategoryHelper categoryHelper;
  final IngredientNormalizer normalizer;

  GenerateShoppingFromMenusUseCase({
    required this.menuRepository,
    required this.shoppingRepository,
    IngredientParser? parser,
    IngredientAggregator? aggregator,
    PriceEstimator? priceEstimator,
    CategoryHelper? categoryHelper,
    IngredientNormalizer? normalizer,
  })  : parser = parser ?? IngredientParser(),
        aggregator = aggregator ?? IngredientAggregator(),
        priceEstimator = priceEstimator ?? PriceEstimator(),
        categoryHelper = categoryHelper ?? CategoryHelper(),
        normalizer = normalizer ?? IngredientNormalizer();

  @override
  Future<List<ShoppingItem>> call(NoParams params) async {
    if (kDebugMode) {
      print('🛒 [GenerateShoppingUseCase] Iniciando generación desde último menú...');
    }

    final menus = await menuRepository.getLatestWeeklyMenu();
    
    if (kDebugMode) {
      print('🛒 [GenerateShoppingUseCase] Menús obtenidos: ${menus.length}');
      for (var menu in menus) {
        print('   - ${menu.name.value}: ${menu.ingredients.length} ingredientes');
      }
    }

    for (final menu in menus) {
      for (final ingredientStr in menu.ingredients) {
        final portion = parser.parse(ingredientStr);
        final normalizedName = normalizer.normalize(portion.name);
        if (normalizedName.isEmpty) continue;
        final normalizedPortion = portion.copyWith(name: normalizedName);
        aggregator.addPortion(normalizedPortion, menu.name.value);
        
        if (kDebugMode) {
          print('🛒 Parseado: "$ingredientStr" → ${normalizedPortion.name} (${normalizedPortion.quantityBase} ${normalizedPortion.unitKind})');
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
      final estimatedPrice = priceEstimator.estimatePrice(agg.unitKind, agg.totalBase);
      final category = categoryHelper.guessCategory(agg.name);

      try {
        final item = ShoppingItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + shoppingItems.length.toString(),
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
          print('✅ Item creado: ${item.name.value} - ${item.quantity.value} [${category.displayName}]');
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