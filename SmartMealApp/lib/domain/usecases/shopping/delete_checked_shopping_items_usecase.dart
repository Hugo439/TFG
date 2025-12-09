import 'package:smartmeal/domain/repositories/shopping_repository.dart';

class DeleteCheckedShoppingItemsUseCase {
  final ShoppingRepository _repo;
  
  DeleteCheckedShoppingItemsUseCase(this._repo);

  Future<void> call(String userId) => _repo.deleteCheckedItems(userId);
}