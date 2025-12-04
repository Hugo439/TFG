import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}