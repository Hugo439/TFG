import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// UseCase para cerrar sesión de usuario.
///
/// Responsabilidad:
/// - Hacer sign out en Firebase Auth
/// - Limpiar estado local (si aplica)
///
/// Entrada:
/// - NoParams
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// await signOutUseCase(NoParams());
/// // Navegar a pantalla de login
/// ```
///
/// Nota: Después del sign out, FirebaseAuth.currentUser será null.
class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.signOut();
  }
}
