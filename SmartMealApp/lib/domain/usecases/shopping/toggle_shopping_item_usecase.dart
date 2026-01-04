import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

/// Parámetros para marcar/desmarcar item de compra.
class ToggleShoppingItemParams {
  final String id;
  final bool isChecked;

  const ToggleShoppingItemParams({required this.id, required this.isChecked});
}

/// UseCase para marcar/desmarcar item como comprado.
///
/// Responsabilidad:
/// - Actualizar campo isChecked de ShoppingItem en Firestore
///
/// Entrada:
/// - ToggleShoppingItemParams:
///   - id: ID del item
///   - isChecked: true (comprado) o false (pendiente)
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// // Marcar como comprado
/// await toggleUseCase(ToggleShoppingItemParams(
///   id: 'item_123',
///   isChecked: true,
/// ));
/// ```
class ToggleShoppingItemUseCase
    implements UseCase<void, ToggleShoppingItemParams> {
  final ShoppingRepository repository;

  ToggleShoppingItemUseCase(this.repository);

  @override
  Future<void> call(ToggleShoppingItemParams params) async {
    return await repository.toggleItemChecked(params.id, params.isChecked);
  }
}
