import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

class GetTotalPriceUseCase implements UseCase<double, NoParams> {
  final ShoppingRepository repository;

  GetTotalPriceUseCase(this.repository);

  @override
  Future<double> call(NoParams params) async {
    return await repository.getTotalPrice();
  }
}