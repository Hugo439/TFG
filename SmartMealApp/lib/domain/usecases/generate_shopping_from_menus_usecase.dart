import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';

class GenerateShoppingFromMenusUseCase implements UseCase<List<ShoppingItem>, NoParams> {
  final MenuRepository menuRepository;
  final ShoppingRepository shoppingRepository;

  GenerateShoppingFromMenusUseCase({
    required this.menuRepository,
    required this.shoppingRepository,
  });

  @override
  Future<List<ShoppingItem>> call(NoParams params) async {
    // Obtener todos los menús
    final menus = await menuRepository.getMenuItems();

    // Mapa para agrupar ingredientes
    final Map<String, _IngredientGroup> ingredientsMap = {};

    // Procesar cada menú
    for (var menu in menus) {
      for (var ingredient in menu.ingredients) {
        final key = ingredient.toLowerCase().trim();

        if (ingredientsMap.containsKey(key)) {
          // Añadir el menú a la lista de usos
          ingredientsMap[key]!.usedInMenus.add(menu.name.value);
        } else {
          // Crear nueva entrada
          ingredientsMap[key] = _IngredientGroup(
            name: ingredient,
            usedInMenus: [menu.name.value],
          );
        }
      }
    }

    // Convertir a lista de ShoppingItems
    final List<ShoppingItem> shoppingItems = [];
    
    for (var entry in ingredientsMap.entries) {
      final ingredient = entry.value;
      
      // Estimar cantidad y precio (esto se puede mejorar con una base de datos de productos)
      final estimatedData = _estimateQuantityAndPrice(ingredient.name);
      
      try {
        final item = ShoppingItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + shoppingItems.length.toString(),
          name: ShoppingItemName(ingredient.name),
          quantity: ShoppingItemQuantity(estimatedData.quantity),
          price: Price(estimatedData.price),
          category: estimatedData.category,
          usedInMenus: ingredient.usedInMenus,
          isChecked: false,
          createdAt: DateTime.now(),
        );

        // Añadir a Firestore
        await shoppingRepository.addShoppingItem(item);
        shoppingItems.add(item);
      } catch (e) {
        // Si falla la validación, continuar con el siguiente
        continue;
      }
    }

    return shoppingItems;
  }

  _EstimatedData _estimateQuantityAndPrice(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();

    // Base de datos simple de estimaciones
    if (lowerName.contains('arroz')) {
      return _EstimatedData('500g', 3.20, 'Supermercado');
    } else if (lowerName.contains('pollo')) {
      return _EstimatedData('1kg', 8.50, 'Carnicería');
    } else if (lowerName.contains('tomate')) {
      return _EstimatedData('250g', 2.80, 'Frutería');
    } else if (lowerName.contains('cebolla')) {
      return _EstimatedData('500g', 1.50, 'Frutería');
    } else if (lowerName.contains('ajo')) {
      return _EstimatedData('100g', 0.80, 'Frutería');
    } else if (lowerName.contains('lechuga')) {
      return _EstimatedData('1 unidad', 1.50, 'Frutería');
    } else if (lowerName.contains('pasta') || lowerName.contains('penne') || lowerName.contains('espagueti')) {
      return _EstimatedData('500g', 2.10, 'Supermercado');
    } else if (lowerName.contains('queso') && lowerName.contains('parmesano')) {
      return _EstimatedData('200g', 4.75, 'Quesería');
    } else if (lowerName.contains('queso') && lowerName.contains('mozzarella')) {
      return _EstimatedData('250g', 3.50, 'Quesería');
    } else if (lowerName.contains('queso')) {
      return _EstimatedData('200g', 3.00, 'Quesería');
    } else if (lowerName.contains('leche')) {
      return _EstimatedData('1L', 1.20, 'Supermercado');
    } else if (lowerName.contains('huevo')) {
      return _EstimatedData('12 unidades', 2.50, 'Supermercado');
    } else if (lowerName.contains('aceite')) {
      return _EstimatedData('1L', 5.50, 'Supermercado');
    } else if (lowerName.contains('sal') || lowerName.contains('pimienta')) {
      return _EstimatedData('1 unidad', 1.00, 'Supermercado');
    } else if (lowerName.contains('pan')) {
      return _EstimatedData('1 unidad', 1.80, 'Panadería');
    } else if (lowerName.contains('carne')) {
      return _EstimatedData('500g', 7.50, 'Carnicería');
    } else if (lowerName.contains('pescado') || lowerName.contains('salmón') || lowerName.contains('merluza')) {
      return _EstimatedData('400g', 9.00, 'Pescadería');
    } else {
      // Por defecto
      return _EstimatedData('1 unidad', 2.50, 'Supermercado');
    }
  }
}

class _IngredientGroup {
  final String name;
  final List<String> usedInMenus;

  _IngredientGroup({
    required this.name,
    required this.usedInMenus,
  });
}

class _EstimatedData {
  final String quantity;
  final double price;
  final String category;

  _EstimatedData(this.quantity, this.price, this.category);
}