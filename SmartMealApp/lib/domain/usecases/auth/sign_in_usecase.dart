import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// Parámetros para el caso de uso de inicio de sesión.
///
/// Encapsula las credenciales necesarias para autenticar a un usuario.
class SignInParams {
  /// Email del usuario.
  final String email;

  /// Contraseña del usuario.
  final String password;

  const SignInParams({required this.email, required this.password});
}

/// Caso de uso para iniciar sesión.
///
/// Delega la validación de credenciales al repositorio, que usará
/// Value Objects (Email, Password) para validar formato y requisitos.
///
/// Flujo:
/// 1. Recibir credenciales desde UI
/// 2. Pasar al repositorio
/// 3. Repository valida con Value Objects
/// 4. Repository llama a Firebase Auth
///
/// Throws:
/// - [ValidationFailure] si email o password inválidos
/// - [AuthFailure] si credenciales incorrectas
/// - [NetworkFailure] si no hay conexión
class SignInUseCase implements UseCase<void, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<void> call(SignInParams params) async {
    // La validación de Value Objects se hace en el repository
    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
