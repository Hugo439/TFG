import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}

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
