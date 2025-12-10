import 'package:smartmeal/domain/services/shopping/price_database.dart';

abstract class PriceRepository {
  Future<Map<String, PriceRange>> getPricesByCategory(String category);
  Future<double> estimatePrice({
    required String ingredientName,
    required String category,
    required double quantityBase,
    required String unitKind,
  });
}