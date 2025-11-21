import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';

class DeleteMenuItemUseCase implements UseCase<void, String> {
  final MenuRepository repository;

  DeleteMenuItemUseCase(this.repository);

  @override
  Future<void> call(String params) async {
    return await repository.deleteMenuItem(params);
  }
}