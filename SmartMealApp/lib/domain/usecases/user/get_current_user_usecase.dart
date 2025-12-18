import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<User?> call(NoParams params) async {
    return _repository.getCurrentUser();
  }
}
