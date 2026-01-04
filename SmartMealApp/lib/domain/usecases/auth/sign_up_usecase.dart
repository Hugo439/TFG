import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

/// Parámetros para el caso de uso de registro de usuario.
///
/// Incluye todos los datos necesarios para crear una cuenta y perfil completo.
class SignUpParams {
  /// Email del usuario (se validará formato).
  final String email;

  /// Contraseña (mínimo 6 caracteres).
  final String password;

  /// Nombre visible del usuario.
  final String displayName;

  /// Altura en centímetros (50-300).
  final int heightCm;

  /// Peso en kilogramos (20-500).
  final double weightKg;

  /// Objetivo: 'lose_weight', 'maintain_weight', 'gain_weight', 'gain_muscle'.
  final String goal;

  /// Lista de alergias separadas por comas (opcional).
  final String? allergies;

  /// Edad del usuario (0-150) (opcional).
  final int? age;

  /// Sexo: 'male' o 'female' (opcional).
  final String? gender;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    this.allergies,
    this.age,
    this.gender,
  });
}

/// Caso de uso para registrar un nuevo usuario.
///
/// Coordina la creación de cuenta en Firebase Auth y perfil en Firestore.
///
/// Flujo:
/// 1. Recibir datos del formulario de registro
/// 2. Pasar al repositorio
/// 3. Repository valida con Value Objects
/// 4. Repository crea usuario en Firebase Auth
/// 5. Repository actualiza displayName en Auth
/// 6. Repository crea perfil en Firestore
///
/// Throws:
/// - [ValidationFailure] si algún dato inválido
/// - [AuthFailure] si email ya existe
/// - [ServerFailure] si falla creación de perfil
class SignUpUseCase implements UseCase<void, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<void> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      heightCm: params.heightCm,
      weightKg: params.weightKg,
      goal: params.goal,
      allergies: params.allergies,
      age: params.age,
      gender: params.gender,
    );
  }
}
