import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// UseCase para eliminar cuenta de usuario completamente.
///
/// Responsabilidad:
/// - Eliminar cuenta de Firebase Auth
/// - Eliminar todos los datos del usuario en Firestore
///   - Perfil de usuario
///   - Menús semanales
///   - Recetas
///   - Lista de compra
///   - Precios personalizados
///   - Mensajes de soporte
///
/// Entrada:
/// - NoParams (usa usuario autenticado actual)
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// // Mostrar confirmación antes
/// final confirmed = await showConfirmDialog('Eliminar cuenta permanentemente?');
/// if (confirmed) {
///   await deleteAccountUseCase(NoParams());
///   // Usuario deslogueado automáticamente
/// }
/// ```
///
/// ADVERTENCIA: Esta operación es IRREVERSIBLE.
class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}
