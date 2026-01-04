import 'package:smartmeal/domain/repositories/shopping_repository.dart';

/// UseCase para eliminar todos los items marcados como comprados.
///
/// Responsabilidad:
/// - Limpiar lista de compra eliminando items con isChecked=true
///
/// Entrada:
/// - userId: ID del usuario
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// // Después de hacer la compra, limpiar items marcados
/// await deleteCheckedUseCase('user123');
/// ```
///
/// Nota: Esta operación es destructiva e irreversible.
class DeleteCheckedShoppingItemsUseCase {
  final ShoppingRepository _repo;

  DeleteCheckedShoppingItemsUseCase(this._repo);

  Future<void> call(String userId) => _repo.deleteCheckedItems(userId);
}
