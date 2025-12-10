import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';

class GetPricesByCategoryUseCase
    implements UseCase<Map<String, PriceRange>, GetPricesByCategoryParams> {
  final PriceRepository priceRepository;

  GetPricesByCategoryUseCase(this.priceRepository);

  @override
  Future<Map<String, PriceRange>> call(GetPricesByCategoryParams params) async {
    return await priceRepository.getPricesByCategory(params.category);
  }
}

class GetPricesByCategoryParams {
  final String category;

  GetPricesByCategoryParams({required this.category});
}