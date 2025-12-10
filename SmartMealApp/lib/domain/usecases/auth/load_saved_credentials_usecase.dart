import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

class LoadSavedCredentialsUseCase 
    implements UseCase<Map<String, String>?, NoParams> {
  final AuthRepository repository;

  LoadSavedCredentialsUseCase(this.repository);

  @override
  Future<Map<String, String>?> call(NoParams params) async {
    return await repository.getSavedCredentials();
  }
}