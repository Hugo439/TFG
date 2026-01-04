import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// UseCase para obtener usuario actual de Firebase Auth.
///
/// Responsabilidad:
/// - Retornar User actual de FirebaseAuth.instance.currentUser
///
/// Entrada:
/// - NoParams
///
/// Salida:
/// - User? (null si no hay usuario autenticado)
///
/// Uso típico:
/// ```dart
/// final user = await getCurrentUserUseCase(NoParams());
///
/// if (user != null) {
///   print('UID: ${user.uid}');
///   print('Email: ${user.email}');
///   print('Display Name: ${user.displayName}');
///   print('Photo URL: ${user.photoURL}');
/// }
/// ```
///
/// Diferencia con GetUserProfileUseCase:
/// - **GetCurrentUser**: Retorna User de Firebase Auth (uid, email, photoURL)
/// - **GetUserProfile**: Retorna UserProfile de Firestore (height, weight, goal, etc.)
///
/// Nota: Este UseCase solo accede a Firebase Auth, no a Firestore.
class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<User?> call(NoParams params) async {
    return _repository.getCurrentUser();
  }
}
