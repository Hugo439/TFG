import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';

class CreateMenuItemUseCase implements UseCase<void, MenuItem> {
  final MenuRepository repository;

  CreateMenuItemUseCase(this.repository);

  @override
  Future<void> call(MenuItem params) async {
    return await repository.createMenuItem(params);
  }
}

//TODO: creo que no se usa