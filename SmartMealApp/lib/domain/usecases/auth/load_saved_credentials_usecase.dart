import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// UseCase para cargar credenciales guardadas.
///
/// Responsabilidad:
/// - Recuperar email/password desde almacenamiento seguro
///
/// Entrada:
/// - NoParams
///
/// Salida:
/// - Map<String, String>? con {'email': ..., 'password': ...}
/// - null si no hay credenciales guardadas
///
/// Uso típico:
/// ```dart
/// // En login screen, al iniciar
/// final credentials = await loadCredentialsUseCase(NoParams());
///
/// if (credentials != null) {
///   // Pre-llenar campos de login
///   emailController.text = credentials['email'] ?? '';
///   passwordController.text = credentials['password'] ?? '';
///   rememberCheckbox = true;
/// }
/// ```
///
/// Formato de retorno:
/// ```dart
/// {
///   'email': 'user@example.com',
///   'password': 'password123',
/// }
/// ```
///
/// Nota: Retorna null si usuario no guardó credenciales o las limpió.
class LoadSavedCredentialsUseCase
    implements UseCase<Map<String, String>?, NoParams> {
  final AuthRepository repository;

  LoadSavedCredentialsUseCase(this.repository);

  @override
  Future<Map<String, String>?> call(NoParams params) async {
    return await repository.getSavedCredentials();
  }
}
