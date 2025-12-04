import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

class GetShoppingItemsUseCase implements UseCase<List<ShoppingItem>, NoParams> {
  final ShoppingRepository repository;

  GetShoppingItemsUseCase(this.repository);

  @override
  Future<List<ShoppingItem>> call(NoParams params) async {
    return await repository.getShoppingItems();
  }
}