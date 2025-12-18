import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String displayName;
  final int heightCm;
  final double weightKg;
  final String goal;
  final String? allergies;
  final int? age;
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
