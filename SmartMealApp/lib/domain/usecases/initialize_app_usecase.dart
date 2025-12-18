import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/app_repository.dart';

class InitializeAppUseCase implements UseCase<void, NoParams> {
  final AppRepository repository;

  InitializeAppUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.initialize();
  }
}
