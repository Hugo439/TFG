import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

class DeleteShoppingItemUseCase implements UseCase<void, String> {
  final ShoppingRepository repository;

  DeleteShoppingItemUseCase(this.repository);

  @override
  Future<void> call(String params) async {
    return await repository.deleteShoppingItem(params);
  }
}