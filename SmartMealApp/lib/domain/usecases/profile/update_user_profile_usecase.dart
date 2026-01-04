import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';

/// UseCase para actualizar perfil de usuario.
///
/// Responsabilidad:
/// - Persistir cambios en UserProfile en Firestore
/// - Actualizar timestamp updatedAt
///
/// Entrada:
/// - UserProfile completo con cambios aplicados
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// // Obtener perfil actual
/// final profile = await getUserProfileUseCase(NoParams());
///
/// // Aplicar cambios
/// final updated = profile.copyWith(
///   weight: Weight(75.0),
///   goal: Goal.loseWeight(),
/// );
///
/// // Guardar cambios
/// await updateUserProfileUseCase(updated);
/// ```
///
/// Campos actualizables:
/// - Datos básicos: displayName, phone
/// - Datos físicos: height, weight, age, gender
/// - Objetivo: goal
/// - Restricciones: allergies
///
/// Nota: Email y photoUrl se actualizan por separado en Firebase Auth.
class UpdateUserProfileUseCase implements UseCase<void, UserProfile> {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<void> call(UserProfile params) async {
    return await repository.updateUserProfile(params);
  }
}
