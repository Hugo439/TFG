import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// Parámetros para guardar credenciales.
class SaveCredentialsParams {
  final String email;
  final String password;
  final bool remember;

  const SaveCredentialsParams({
    required this.email,
    required this.password,
    required this.remember,
  });
}

/// UseCase para guardar o limpiar credenciales de login.
///
/// Responsabilidad:
/// - Guardar email/password en almacenamiento seguro (si remember=true)
/// - Limpiar credenciales guardadas (si remember=false)
///
/// Entrada:
/// - SaveCredentialsParams:
///   - email: email del usuario
///   - password: password del usuario
///   - remember: true para guardar, false para limpiar
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// // Usuario marca "Recordar credenciales" en login
/// await saveCredentialsUseCase(SaveCredentialsParams(
///   email: 'user@example.com',
///   password: 'password123',
///   remember: true, // Guardar
/// ));
///
/// // Usuario desmarca "Recordar credenciales"
/// await saveCredentialsUseCase(SaveCredentialsParams(
///   email: '',
///   password: '',
///   remember: false, // Limpiar
/// ));
/// ```
///
/// Seguridad:
/// - Usa FlutterSecureStorage para encriptar credenciales
/// - Solo guarda si remember=true
///
/// ADVERTENCIA: Guardar password en dispositivo es menos seguro.
/// Considerar usar solo biometría o tokens.
class SaveCredentialsUseCase implements UseCase<void, SaveCredentialsParams> {
  final AuthRepository repository;

  SaveCredentialsUseCase(this.repository);

  @override
  Future<void> call(SaveCredentialsParams params) async {
    if (params.remember) {
      return await repository.saveCredentials(params.email, params.password);
    } else {
      return await repository.clearCredentials();
    }
  }
}
