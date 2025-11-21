import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';

class GetMenuItemsUseCase implements UseCase<List<MenuItem>, NoParams> {
  final MenuRepository repository;

  GetMenuItemsUseCase(this.repository);

  @override
  Future<List<MenuItem>> call(NoParams params) async {
    return await repository.getMenuItems();
  }
}