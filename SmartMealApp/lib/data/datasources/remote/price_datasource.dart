import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';

/// Interfaz para datasources de precios.
///
/// Define el contrato para obtener precios de ingredientes desde
/// diferentes fuentes (Firestore, API externa, hardcoded, etc.).
abstract class PriceDatasource {
  /// Obtiene todos los precios de una categoría.
  ///
  /// Returns: Mapa ingrediente → PriceRange.
  Future<Map<String, PriceRange>> getPrices(String category);

  /// Estima el precio de un ingrediente específico.
  ///
  /// Returns: Precio estimado por unidad (kg, litro, o pieza).
  Future<double> getEstimatedPrice({
    required String ingredientName,
    required String category,
  });
}

/// Implementación de PriceDatasource usando Firestore.
///
/// Lee precios desde la colección 'price_catalog' en Firestore.
///
/// Estructura en Firestore:
/// ```
/// price_catalog/{ingredientId}
///   - category: string (ej: 'carnes_y_pescados')
///   - displayName: string (ej: 'Pollo pechuga')
///   - priceRef: number (precio de referencia por kg/l/ud)
///   - unitKind: string ('weight', 'liter', 'piece')
/// ```
///
/// Características:
/// - **Caché en memoria**: Guarda precios por categoría para evitar consultas repetidas
/// - **Aliases de categorías**: Maneja variaciones de nombres ("frutas_y_verduras", "frutas-y-verduras", etc.)
/// - **Rango de precios**: Calcula min/max como ±20% del precio de referencia
/// - **Búsqueda flexible**: Encuentra ingredientes por nombre parcial
///
/// Nota: Si no encuentra precio, devuelve 0 (el repositorio usará fallback).
class FirestorePriceDatasource implements PriceDatasource {
  final FirebaseFirestore _firestore;
  final Map<String, Map<String, PriceRange>> _cache = {};

  //TODO: poner bien el nombre de las categorias
  // Mapeo de categorías alternativas si la primera no existe
  static const _categoryAliases = {
    'frutas_y_verduras': [
      'frutas_verduras',
      'frutas y verduras',
      'frutas-y-verduras',
    ],
    'carnes_y_pescados': [
      'carnes_pescados',
      'carnes y pescados',
      'carnes-y-pescados',
    ],
    'lacteos': ['lacteo', 'lácteos'],
    'panaderia': ['pan', 'panadería'],
    'bebidas': ['bebida'],
    'snacks': ['snack'],
  };

  FirestorePriceDatasource(this._firestore);

  /// Obtiene todos los precios de una categoría desde Firestore.
  ///
  /// [category] - Nombre de la categoría (ej: 'frutas_y_verduras', 'lacteos').
  ///
  /// Returns:
  /// - Mapa ingrediente → PriceRange (con min, max, avg)
  /// - Mapa vacío si no se encuentra la categoría o hay error
  ///
  /// Proceso:
  /// 1. Buscar en caché primero
  /// 2. Si no hay caché, consultar Firestore por categoría
  /// 3. Intentar con aliases si no encuentra (ej: frutas_y_verduras, frutas-y-verduras)
  /// 4. Convertir a PriceRange (min = avg * 0.8, max = avg * 1.2)
  /// 5. Guardar en caché
  ///
  /// Nota: Los errores se silencian y se devuelve mapa vacío.
  @override
  Future<Map<String, PriceRange>> getPrices(String category) async {
    try {
      // Buscar en caché primero
      if (_cache.containsKey(category)) {
        if (kDebugMode) {
          debugPrint('💾 [PriceDatasource] Precios en caché para: $category');
        }
        return _cache[category]!;
      }

      // Obtener de price_catalog en Firestore (intenta categoría principal + aliases)
      final categoriesToTry = [category];
      if (_categoryAliases.containsKey(category)) {
        categoriesToTry.addAll(_categoryAliases[category]!);
      }

      QuerySnapshot? query;
      String? foundCategory;

      for (final cat in categoriesToTry) {
        query = await _firestore
            .collection('price_catalog')
            .where('category', isEqualTo: cat)
            .get();

        if (query.docs.isNotEmpty) {
          foundCategory = cat;
          break;
        }
      }

      if (query == null || query.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [PriceDatasource] Categoría no encontrada: $category (intentadas: ${categoriesToTry.join(", ")})',
          );
        }
        return {};
      }

      if (kDebugMode && foundCategory != category) {
        debugPrint(
          'ℹ️ [PriceDatasource] Categoría mapeada: $category → $foundCategory',
        );
      }

      // Convertir a PriceRange
      final prices = <String, PriceRange>{};
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final displayName = data['displayName'] as String? ?? doc.id;
        prices[displayName.toLowerCase()] = PriceRange(
          min: (data['priceRef'] as num).toDouble() * 0.8,
          max: (data['priceRef'] as num).toDouble() * 1.2,
          avg: (data['priceRef'] as num).toDouble(),
          unit: _parseUnitType(data['unitKind'] as String?),
        );
      }

      // Guardar en caché
      _cache[category] = prices;

      if (kDebugMode) {
        debugPrint(
          '✅ [PriceDatasource] Precios cargados para: $category (${prices.length} ingredientes)',
        );
      }

      return prices;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PriceDatasource] Error obteniendo precios: $e');
      }
      return {};
    }
  }

  /// Estima el precio por unidad de un ingrediente.
  ///
  /// [ingredientName] - Nombre del ingrediente a buscar.
  /// [category] - Categoría del ingrediente.
  ///
  /// Returns:
  /// - Precio promedio por unidad (kg, litro, o pieza)
  /// - 0 si no se encuentra
  ///
  /// Búsqueda flexible:
  /// - Convierte a minúsculas
  /// - Busca coincidencias parciales ("pollo" encuentra "pollo pechuga")
  /// - Usa el primer match encontrado
  ///
  /// Nota: Si devuelve 0, el repositorio usará PriceDatabase como fallback.
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
            debugPrint(
              '💰 [PriceDatasource] Precio encontrado: $key = €${priceRange.avg}',
            );
          }
          break;
        }
      }

      if (priceRange == null) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [PriceDatasource] Precio no encontrado para: $ingredientName en $category',
          );
        }
        return 0;
      }

      return priceRange.avg;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PriceDatasource] Error estimando precio: $e');
      }
      return 0;
    }
  }

  /// Convierte string de unitKind a enum UnitType.
  ///
  /// Mapeo:
  /// - 'liter' → UnitType.liter
  /// - 'piece' → UnitType.piece
  /// - default → UnitType.weight
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

  /// Limpia el caché de precios.
  ///
  /// Útil para forzar recarga desde Firestore (ej: después de actualizar catálogo).
  void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      debugPrint('🗑️ [PriceDatasource] Caché limpiado');
    }
  }
}
