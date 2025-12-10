import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

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

class SaveCredentialsUseCase 
    implements UseCase<void, SaveCredentialsParams> {
  final AuthRepository repository;

  SaveCredentialsUseCase(this.repository);

  @override
  Future<void> call(SaveCredentialsParams params) async {
    if (params.remember) {
      return await repository.saveCredentials(
        params.email,
        params.password,
      );
    } else {
      return await repository.clearCredentials();
    }
  }
}