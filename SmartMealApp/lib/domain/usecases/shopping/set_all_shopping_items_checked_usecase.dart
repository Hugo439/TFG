import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

/// UseCase para marcar/desmarcar todos los items de la lista.
///
/// Responsabilidad:
/// - Actualizar isChecked de todos los ShoppingItem del usuario
///
/// Entrada:
/// - bool: true (marcar todos), false (desmarcar todos)
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// // Marcar todos como comprados
/// await setAllCheckedUseCase(true);
///
/// // Desmarcar todos (resetear lista)
/// await setAllCheckedUseCase(false);
/// ```
///
/// Casos de uso:
/// - **Marcar todos (true)**: Usuario completó toda la compra
/// - **Desmarcar todos (false)**: Usuario quiere resetear lista
///
/// Nota: Operación batch en Firestore para eficiencia.
class SetAllShoppingItemsCheckedUseCase implements UseCase<void, bool> {
  final ShoppingRepository repository;
  SetAllShoppingItemsCheckedUseCase(this.repository);

  @override
  Future<void> call(bool params) {
    return repository.setAllChecked(params);
  }
}
