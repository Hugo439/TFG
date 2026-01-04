import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/datasources/remote/price_datasource.dart';
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';

/// Implementación del repositorio de precios.
///
/// Proporciona estimaciones de precios para ingredientes usando:
/// - **Firestore**: Precios personalizados por categoría (fuente principal)
/// - **PriceDatabase**: Precios hardcoded como fallback
///
/// Estrategia de estimación:
/// 1. Consultar precio por unidad en Firestore (por ingrediente y categoría)
/// 2. Si encuentra (precio > 0), calcular precio total según cantidad y unidad
/// 3. Si no encuentra, usar fallback de PriceDatabase (hardcoded)
///
/// Cálculo por tipo de unidad:
/// - **Peso (weight)**: precio/kg × (gramos / 1000)
/// - **Volumen (volume)**: precio/litro × (ml / 1000)
/// - **Unidad (unit)**: precio/unidad × cantidad
///
/// Nota: Los precios se limitan a rangos razonables (0.1 - 100€).
class PriceRepositoryImpl implements PriceRepository {
  final PriceDatasource _priceDatasource;

  PriceRepositoryImpl(this._priceDatasource);

  /// Obtiene todos los precios de una categoría desde Firestore.
  ///
  /// [category] - Nombre de la categoría (ej: 'carnes_y_pescados', 'lacteos').
  ///
  /// Returns:
  /// - Mapa ingrediente → PriceRange si existe la categoría
  /// - Mapa vacío si falla o no hay datos
  ///
  /// Nota: Los errores se silencian y se devuelve mapa vacío.
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

  /// Estima el precio de un ingrediente con cantidad específica.
  ///
  /// Parámetros:
  /// [ingredientName] - Nombre del ingrediente (normalizado).
  /// [category] - Categoría del ingrediente.
  /// [quantityBase] - Cantidad en unidad base (gramos para peso, ml para volumen, unidades para unit).
  /// [unitKind] - Tipo de unidad: 'weight', 'volume', o 'unit'.
  ///
  /// Returns: Precio estimado en euros.
  ///
  /// Estrategia:
  /// 1. Consultar precio/unidad en Firestore (por nombre + categoría)
  /// 2. Si encuentra (> 0), calcular precio total con [_calculatePrice]
  /// 3. Si no encuentra o es 0, usar fallback de PriceDatabase (hardcoded)
  ///
  /// Nota: Siempre devuelve un precio válido (nunca falla, usa fallback).
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

  /// Calcula el precio total según cantidad y tipo de unidad.
  ///
  /// [pricePerUnit] - Precio por unidad base (kg, litro, o unidad).
  /// [quantityBase] - Cantidad en unidad base.
  /// [unitKind] - Tipo: 'weight', 'volume', o 'unit'.
  ///
  /// Returns: Precio calculado, limitado a rangos razonables.
  ///
  /// Cálculos:
  /// - weight: precio/kg × (gramos / 1000) [límite: 0.1 - 100€]
  /// - volume: precio/litro × (ml / 1000) [límite: 0.1 - 50€]
  /// - unit: precio/unidad × cantidad [límite: 0.1 - 50€]
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
