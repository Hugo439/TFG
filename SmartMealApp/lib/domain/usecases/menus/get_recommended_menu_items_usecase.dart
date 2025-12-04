import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';

class GetRecommendedMenuItemsParams {
  final int limit;

  const GetRecommendedMenuItemsParams({this.limit = 3});
}

class GetRecommendedMenuItemsUseCase implements UseCase<List<MenuItem>, GetRecommendedMenuItemsParams> {
  final MenuRepository repository;

  GetRecommendedMenuItemsUseCase(this.repository);

  @override
  Future<List<MenuItem>> call(GetRecommendedMenuItemsParams params) async {
    return await repository.getRecommendedMenuItems(params.limit);
  }
}
//TODO: solo se usa en el service locator, asiq posiblemente sea prescindible