import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

class SetAllShoppingItemsCheckedUseCase implements UseCase<void, bool> {
  final ShoppingRepository repository;
  SetAllShoppingItemsCheckedUseCase(this.repository);

  @override
  Future<void> call(bool params) {
    return repository.setAllChecked(params);
  }
}
