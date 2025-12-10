import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/seasonal_pricing_service.dart';
import 'package:smartmeal/domain/services/shopping/price_cache_service.dart';

enum UnitType {
  weight, // €/kg
  liter, // €/L
  piece, // €/unidad
}

class PriceRange {
  final double min;
  final double max;
  final double avg;
  final UnitType unit;

  const PriceRange({
    required this.min,
    required this.max,
    required this.avg,
    this.unit = UnitType.weight,
  });

  factory PriceRange.fromMap(Map<String, dynamic> map) {
    return PriceRange(
      min: (map['min'] as num).toDouble(),
      max: (map['max'] as num).toDouble(),
      avg: (map['avg'] as num).toDouble(),
      unit: _parseUnitType(map['unit'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'min': min,
      'max': max,
      'avg': avg,
      'unit': _unitTypeToString(unit),
    };
  }

  static UnitType _parseUnitType(String? unit) {
    switch (unit) {
      case 'liter':
        return UnitType.liter;
      case 'piece':
        return UnitType.piece;
      default:
        return UnitType.weight;
    }
  }

  static String _unitTypeToString(UnitType unit) {
    switch (unit) {
      case UnitType.liter:
        return 'liter';
      case UnitType.piece:
        return 'piece';
      case UnitType.weight:
        return 'weight';
    }
  }

  @override
  String toString() => 'PriceRange(min: €$min, max: €$max, avg: €$avg, unit: ${unit.name})';
}

class PriceDatabase {
  static final _cache = PriceCacheService();

  /// Precios promedio por categoría como fallback (€/kg o €/L)
  static const Map<String, double> pricesByCategory = {
    'frutas_y_verduras': 3.50,  // €/kg (antes: 2.5)
    'carnes_y_pescados': 15.00, // €/kg (antes: 12.0)
    'lacteos': 4.50,            // €/kg (antes: 8.0) - ajustado porque leche es €/L
    'panaderia': 5.00,          // €/kg (antes: 3.0)
    'bebidas': 1.20,            // €/L (antes: 1.5)
    'snacks': 12.00,            // €/kg (antes: 10.0)
    'otros': 5.50,              // €/kg (antes: 4.0)
  };

  /// Precios específicos por ingrediente (€ por unidad o €/kg)
  static const Map<String, PriceInfo> specificPrices = {
    // ===== HUEVOS Y LÁCTEOS =====
    'huevo': PriceInfo(pricePerUnit: 0.25, unitType: UnitType.piece),  // €0.25/huevo
    'leche': PriceInfo(pricePerUnit: 1.20, unitType: UnitType.liter),  // €1.20/L
    'yogur': PriceInfo(pricePerUnit: 3.50, unitType: UnitType.weight), // €3.50/kg
    'queso': PriceInfo(pricePerUnit: 12.00, unitType: UnitType.weight), // €12/kg
    
    // ===== CARNES =====
    'pollo': PriceInfo(pricePerUnit: 8.00, unitType: UnitType.weight),  // €8/kg
    'pavo': PriceInfo(pricePerUnit: 10.00, unitType: UnitType.weight),
    'carne res': PriceInfo(pricePerUnit: 18.00, unitType: UnitType.weight),
    
    // ===== PESCADOS =====
    'salmon': PriceInfo(pricePerUnit: 20.00, unitType: UnitType.weight),
    'atun': PriceInfo(pricePerUnit: 15.00, unitType: UnitType.weight),
    'bacalao': PriceInfo(pricePerUnit: 16.00, unitType: UnitType.weight),
    
    // ===== FRUTAS Y VERDURAS =====
    'aguacate': PriceInfo(pricePerUnit: 2.50, unitType: UnitType.piece), // €2.50/unidad
    'platano': PriceInfo(pricePerUnit: 2.00, unitType: UnitType.weight), // €2/kg
    'tomate': PriceInfo(pricePerUnit: 3.00, unitType: UnitType.weight),
    'patata': PriceInfo(pricePerUnit: 1.50, unitType: UnitType.weight),
    
    // ===== PANADERÍA =====
    'pan': PriceInfo(pricePerUnit: 1.50, unitType: UnitType.piece),
    'tortilla': PriceInfo(pricePerUnit: 0.40, unitType: UnitType.piece), // €0.40/tortilla
  };

  static double getEstimatedPrice({
    required String ingredientName,
    required String category,
    required double quantityBase,
    required String unitKind,
    bool useCache = true,
    bool applySeasonalAdjustment = true,
  }) {
    // PASO 1: Normalizar nombre
    final normalizedName = SmartIngredientNormalizer().normalize(ingredientName);

    // PASO 2: Intentar obtener desde caché
    if (useCache) {
      final cacheKey = PriceCacheService.generateKey(
        ingredientName: normalizedName,
        category: category,
        quantityBase: quantityBase,
        unitKind: unitKind,
      );

      final cachedPrice = _cache.get(cacheKey);
      if (cachedPrice != null) {
        return cachedPrice;
      }
    }

    // PASO 3: Buscar precio específico (con fuzzy matching)
    double basePrice;
    
    if (specificPrices.containsKey(normalizedName)) {
      final info = specificPrices[normalizedName]!;
      basePrice = _calculatePrice(
        pricePerUnit: info.pricePerUnit,
        quantityBase: quantityBase,
        unitKind: unitKind,
        unitType: info.unitType,
      );
    } else {
      // Intentar fuzzy match
      final bestMatch = SmartIngredientNormalizer.findBestMatch(
        normalizedName,
        specificPrices.keys.toList(),
        minScore: 80,
      );

      if (bestMatch != null) {
        final info = specificPrices[bestMatch]!;
        basePrice = _calculatePrice(
          pricePerUnit: info.pricePerUnit,
          quantityBase: quantityBase,
          unitKind: unitKind,
          unitType: info.unitType,
        );
      } else {
        // Usar precio por categoría
        final categoryPrice = pricesByCategory[category.toLowerCase()] ?? 5.0;
        basePrice = _calculatePrice(
          pricePerUnit: categoryPrice,
          quantityBase: quantityBase,
          unitKind: unitKind,
          unitType: UnitType.weight,
        );
      }
    }

    // PASO 4: Aplicar ajuste estacional
    double finalPrice = basePrice;
    if (applySeasonalAdjustment) {
      finalPrice = SeasonalPricingService.applySeasonalAdjustment(
        basePrice,
        normalizedName,
      );
    }

    // PASO 5: Guardar en caché
    if (useCache) {
      final cacheKey = PriceCacheService.generateKey(
        ingredientName: normalizedName,
        category: category,
        quantityBase: quantityBase,
        unitKind: unitKind,
      );

      _cache.set(
        cacheKey,
        finalPrice,
        source: 'calculated',
      );
    }

    return finalPrice;
  }

  static double _calculatePrice({
    required double pricePerUnit,
    required double quantityBase,
    required String unitKind,
    required UnitType unitType,
  }) {
    // Precio por unidad (huevos, tortillas, aguacates...)
    if (unitType == UnitType.piece && unitKind == 'unit') {
      return (pricePerUnit * quantityBase).clamp(0.10, 100.0);
    }

    // Precio por peso (€/kg) - convertir de gramos a kg
    if (unitType == UnitType.weight && unitKind == 'weight') {
      final kg = quantityBase / 1000.0;
      return (pricePerUnit * kg).clamp(0.10, 200.0);
    }

    // Precio por volumen (€/L) - convertir de ml a litros
    if (unitType == UnitType.liter && unitKind == 'volume') {
      final liters = quantityBase / 1000.0;
      return (pricePerUnit * liters).clamp(0.10, 100.0);
    }

    // Fallback: tratarlo como peso
    final kg = quantityBase / 1000.0;
    return (pricePerUnit * kg).clamp(0.10, 200.0);
  }

  /// Limpia caché de precios
  static void clearCache() {
    _cache.clear();
  }

  /// Obtiene estadísticas de caché
  static Map<String, dynamic> getCacheStats() {
    return _cache.getStats();
  }
}

/// Info de precio específico
class PriceInfo {
  final double pricePerUnit;
  final UnitType unitType;

  const PriceInfo({
    required this.pricePerUnit,
    required this.unitType,
  });
}