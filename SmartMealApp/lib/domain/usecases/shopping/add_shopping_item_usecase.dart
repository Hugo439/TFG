import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

class AddShoppingItemUseCase implements UseCase<void, ShoppingItem> {
  final ShoppingRepository repository;

  AddShoppingItemUseCase(this.repository);

  @override
  Future<void> call(ShoppingItem params) async {
    return await repository.addShoppingItem(params);
  }
}
