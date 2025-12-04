import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

class ToggleShoppingItemParams {
  final String id;
  final bool isChecked;

  const ToggleShoppingItemParams({
    required this.id,
    required this.isChecked,
  });
}

class ToggleShoppingItemUseCase implements UseCase<void, ToggleShoppingItemParams> {
  final ShoppingRepository repository;

  ToggleShoppingItemUseCase(this.repository);

  @override
  Future<void> call(ToggleShoppingItemParams params) async {
    return await repository.toggleItemChecked(params.id, params.isChecked);
  }
}