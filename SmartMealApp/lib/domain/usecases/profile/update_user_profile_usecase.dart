import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';

class UpdateUserProfileUseCase implements UseCase<void, UserProfile> {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<void> call(UserProfile params) async {
    return await repository.updateUserProfile(params);
  }
}
