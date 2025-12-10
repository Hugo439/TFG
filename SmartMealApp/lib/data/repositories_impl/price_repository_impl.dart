import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/datasources/remote/price_datasource.dart';
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';

class PriceRepositoryImpl implements PriceRepository {
  final PriceDatasource _priceDatasource;

  PriceRepositoryImpl(this._priceDatasource);

  @override
  Future<Map<String, PriceRange>> getPricesByCategory(String category) async {
    try {
      return await _priceDatasource.getPrices(category);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceRepository] Error obteniendo categoría $category: $e');
      }
      return {};
    }
  }

  @override
  Future<double> estimatePrice({
    required String ingredientName,
    required String category,
    required double quantityBase,
    required String unitKind,
  }) async {
    try {
      // Obtener precio desde Firestore
      final pricePerUnit = await _priceDatasource.getEstimatedPrice(
        ingredientName: ingredientName,
        category: category,
      );

      // Si no encuentra en Firestore, usar fallback hardcoded
      if (pricePerUnit == 0) {
        if (kDebugMode) {
          print('⚠️ [PriceRepository] Usando fallback para: $ingredientName');
        }
        return PriceDatabase.getEstimatedPrice(
          ingredientName: ingredientName,
          category: category,
          quantityBase: quantityBase,
          unitKind: unitKind,
        );
      }

      // Calcular precio con valor de Firestore
      return _calculatePrice(
        pricePerUnit: pricePerUnit,
        quantityBase: quantityBase,
        unitKind: unitKind,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceRepository] Error estimando precio: $e');
      }
      // Fallback final
      return PriceDatabase.getEstimatedPrice(
        ingredientName: ingredientName,
        category: category,
        quantityBase: quantityBase,
        unitKind: unitKind,
      );
    }
  }

  double _calculatePrice({
    required double pricePerUnit,
    required double quantityBase,
    required String unitKind,
  }) {
    if (unitKind == 'weight') {
      final kg = quantityBase / 1000.0;
      return (pricePerUnit * kg).clamp(0.1, 100.0);
    }
    if (unitKind == 'volume') {
      final liters = quantityBase / 1000.0;
      return (pricePerUnit * liters).clamp(0.1, 50.0);
    }
    return (pricePerUnit * quantityBase).clamp(0.1, 50.0);
  }
}