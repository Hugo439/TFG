import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

/// UseCase para añadir un item a la lista de compra.
///
/// Responsabilidad:
/// - Delegar al repositorio para persistir ShoppingItem en Firestore
///
/// Entrada:
/// - ShoppingItem con todos los campos (id, name, quantity, price, category, etc.)
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// final item = ShoppingItem(
///   id: 'generated_id',
///   name: ShoppingItemName('Pollo'),
///   quantity: ShoppingItemQuantity('500 g'),
///   price: Price(4.0),
///   category: ShoppingItemCategory.carnesYPescados,
///   usedInMenus: ['menu_id'],
///   isChecked: false,
///   createdAt: DateTime.now(),
/// );
/// await addShoppingItemUseCase(item);
/// ```
class AddShoppingItemUseCase implements UseCase<void, ShoppingItem> {
  final ShoppingRepository repository;

  AddShoppingItemUseCase(this.repository);

  @override
  Future<void> call(ShoppingItem params) async {
    return await repository.addShoppingItem(params);
  }
}
