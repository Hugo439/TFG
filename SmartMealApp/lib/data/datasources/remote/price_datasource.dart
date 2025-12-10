import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';

abstract class PriceDatasource {
  Future<Map<String, PriceRange>> getPrices(String category);
  Future<double> getEstimatedPrice({
    required String ingredientName,
    required String category,
  });
}

class FirestorePriceDatasource implements PriceDatasource {
  final FirebaseFirestore _firestore;
  final Map<String, Map<String, PriceRange>> _cache = {};

  FirestorePriceDatasource(this._firestore);

  @override
  Future<Map<String, PriceRange>> getPrices(String category) async {
    try {
      // Buscar en caché primero
      if (_cache.containsKey(category)) {
        if (kDebugMode) {
          print('💾 [PriceDatasource] Precios en caché para: $category');
        }
        return _cache[category]!;
      }

      // Obtener de Firestore
      final doc = await _firestore.collection('prices').doc('ingredients').get();
      
      if (!doc.exists) {
        if (kDebugMode) {
          print('⚠️ [PriceDatasource] No hay documento de precios en Firestore');
        }
        return {};
      }

      final data = doc.data() as Map<String, dynamic>;
      final categoryData = data[category] as Map<String, dynamic>?;
      
      if (categoryData == null) {
        if (kDebugMode) {
          print('⚠️ [PriceDatasource] Categoría no encontrada: $category');
        }
        return {};
      }

      // Convertir a PriceRange
      final prices = <String, PriceRange>{};
      categoryData.forEach((ingredient, priceData) {
        if (priceData is Map<String, dynamic>) {
          prices[ingredient] = PriceRange(
            min: (priceData['min'] as num).toDouble(),
            max: (priceData['max'] as num).toDouble(),
            avg: (priceData['avg'] as num).toDouble(),
            unit: _parseUnitType(priceData['unit'] as String?),
          );
        }
      });

      // Guardar en caché
      _cache[category] = prices;
      
      if (kDebugMode) {
        print('✅ [PriceDatasource] Precios cargados para: $category (${prices.length} ingredientes)');
      }

      return prices;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceDatasource] Error obteniendo precios: $e');
      }
      return {};
    }
  }

  @override
  Future<double> getEstimatedPrice({
    required String ingredientName,
    required String category,
  }) async {
    try {
      final prices = await getPrices(category);
      
      // Buscar ingrediente en la categoría
      PriceRange? priceRange;
      final n = ingredientName.toLowerCase();
      
      for (final key in prices.keys) {
        if (n.contains(key) || key.contains(n)) {
          priceRange = prices[key];
          if (kDebugMode && priceRange != null) {
            print('💰 [PriceDatasource] Precio encontrado: $key = €${priceRange.avg}');
          }
          break;
        }
      }

      if (priceRange == null) {
        if (kDebugMode) {
          print('⚠️ [PriceDatasource] Precio no encontrado para: $ingredientName en $category');
        }
        return 0;
      }

      return priceRange.avg;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceDatasource] Error estimando precio: $e');
      }
      return 0;
    }
  }

  UnitType _parseUnitType(String? unit) {
    switch (unit) {
      case 'liter':
        return UnitType.liter;
      case 'piece':
        return UnitType.piece;
      default:
        return UnitType.weight;
    }
  }

  /// Limpiar caché (útil para refresh)
  void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      print('🗑️ [PriceDatasource] Caché limpiado');
    }
  }
}