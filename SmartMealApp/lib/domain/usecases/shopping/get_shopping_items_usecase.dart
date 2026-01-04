import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

/// UseCase para obtener lista completa de compra del usuario.
///
/// Responsabilidad:
/// - Recuperar todos los ShoppingItem de Firestore
///
/// Entrada:
/// - NoParams (usa usuario autenticado de FirebaseAuth)
///
/// Salida:
/// - List<ShoppingItem> ordenada por createdAt descendente
///
/// Uso típico:
/// ```dart
/// final items = await getShoppingItemsUseCase(NoParams());
/// for (final item in items) {
///   print('${item.name.value}: ${item.quantity.value}');
/// }
/// ```
///
/// Nota: Retorna lista vacía si usuario no tiene items.
class GetShoppingItemsUseCase implements UseCase<List<ShoppingItem>, NoParams> {
  final ShoppingRepository repository;

  GetShoppingItemsUseCase(this.repository);

  @override
  Future<List<ShoppingItem>> call(NoParams params) async {
    return await repository.getShoppingItems();
  }
}
