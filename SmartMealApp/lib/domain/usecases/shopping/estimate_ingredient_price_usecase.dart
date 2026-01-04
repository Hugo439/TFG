import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// UseCase para estimar precio de un ingrediente.
///
/// Responsabilidad:
/// - Delegar al PriceRepository para calcular precio estimado
/// - Convertir UnitKind enum a string para el repositorio
///
/// Entrada:
/// - EstimateIngredientPriceParams:
///   - ingredientName: nombre del ingrediente
///   - category: categoría (carnesYPescados, lacteos, etc.)
///   - quantityBase: cantidad en unidad base (g, ml, ud)
///   - unitKind: tipo de unidad (weight, volume, unit)
///
/// Salida:
/// - double con precio estimado en euros
///
/// Uso típico:
/// ```dart
/// final price = await estimateUseCase(EstimateIngredientPriceParams(
///   ingredientName: 'pollo',
///   category: 'carnesYPescados',
///   quantityBase: 500, // 500g
///   unitKind: UnitKind.weight,
/// ));
/// print('Precio: €$price');
/// ```
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

/// Parámetros para estimación de precio de ingrediente.
///
/// Campos:
/// - **ingredientName**: nombre del ingrediente (será normalizado)
/// - **category**: categoría para buscar precios
/// - **quantityBase**: cantidad en unidad base (g, ml, o unidades)
/// - **unitKind**: tipo de unidad (weight, volume, unit)
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
