import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
