import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';

class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<UserProfile> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}