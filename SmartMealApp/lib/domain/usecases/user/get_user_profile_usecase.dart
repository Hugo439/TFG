import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';

/// UseCase para obtener perfil completo del usuario.
///
/// Responsabilidad:
/// - Recuperar UserProfile desde Firestore
/// - Combinar datos de Firestore + Firebase Auth (email, photoUrl)
///
/// Entrada:
/// - NoParams (usa usuario autenticado de Firebase Auth)
///
/// Salida:
/// - UserProfile con todos los campos:
///   - Datos básicos: displayName, email, phone, photoUrl
///   - Datos físicos: height, weight, age, gender
///   - Objetivo: goal (perder peso, ganar músculo, etc.)
///   - Restricciones: allergies
///   - Timestamps: createdAt, updatedAt
///
/// Uso típico:
/// ```dart
/// final profile = await getUserProfileUseCase(NoParams());
/// print('Usuario: ${profile.displayName.value}');
/// print('Peso: ${profile.weight.value} kg');
/// print('Objetivo: ${profile.goal.displayName}');
/// ```
///
/// Excepciones:
/// - Lanza excepción si usuario no autenticado
/// - Lanza excepción si perfil no existe en Firestore
class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<UserProfile> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}
