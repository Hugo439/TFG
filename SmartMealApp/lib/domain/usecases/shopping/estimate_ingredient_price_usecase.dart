import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_unit_kind.dart';

class EstimateIngredientPriceUseCase
    implements UseCase<double, EstimateIngredientPriceParams> {
  final PriceRepository priceRepository;

  EstimateIngredientPriceUseCase(this.priceRepository);

  @override
  Future<double> call(EstimateIngredientPriceParams params) async {
    return await priceRepository.estimatePrice(
      ingredientName: params.ingredientName,
      category: params.category,
      quantityBase: params.quantityBase,
      unitKind: params.unitKind == UnitKind.weight
          ? 'weight'
          : params.unitKind == UnitKind.volume
          ? 'volume'
          : 'unit',
    );
  }
}

class EstimateIngredientPriceParams {
  final String ingredientName;
  final String category;
  final double quantityBase;
  final UnitKind unitKind;

  EstimateIngredientPriceParams({
    required this.ingredientName,
    required this.category,
    required this.quantityBase,
    required this.unitKind,
  });
}
