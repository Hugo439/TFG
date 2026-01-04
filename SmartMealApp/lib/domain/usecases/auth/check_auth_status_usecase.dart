import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// UseCase para verificar si hay usuario autenticado.
///
/// Responsabilidad:
/// - Verificar estado de autenticación en Firebase Auth
///
/// Entrada:
/// - NoParams
///
/// Salida:
/// - bool: true si hay usuario autenticado, false si no
///
/// Uso típico:
/// ```dart
/// // En splash screen o app initialization
/// final isAuthenticated = await checkAuthStatusUseCase(NoParams());
///
/// if (isAuthenticated) {
///   // Ir a home screen
///   navigator.pushReplacementNamed('/home');
/// } else {
///   // Ir a login screen
///   navigator.pushReplacementNamed('/login');
/// }
/// ```
///
/// Equivalente a: FirebaseAuth.instance.currentUser != null
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
