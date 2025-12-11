import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

enum Season { spring, summer, autumn, winter }

class SeasonalPricingService {
  /// Mapa de ingredientes estacionales y sus multiplicadores
  static const Map<String, Map<Season, double>> _seasonalMultipliers = {
    // FRUTAS
    'fresa': {
      Season.spring: 0.7,
      Season.summer: 0.8,
      Season.autumn: 1.4,
      Season.winter: 1.5,
    },
    'sandia': {
      Season.spring: 1.3,
      Season.summer: 0.6,
      Season.autumn: 1.4,
      Season.winter: 2.0,
    },
    'naranja': {
      Season.spring: 1.2,
      Season.summer: 1.5,
      Season.autumn: 0.9,
      Season.winter: 0.7,
    },
    'melocoton': {
      Season.spring: 1.4,
      Season.summer: 0.7,
      Season.autumn: 1.3,
      Season.winter: 2.0,
    },
    'uva': {
      Season.spring: 1.5,
      Season.summer: 1.2,
      Season.autumn: 0.7,
      Season.winter: 1.4,
    },
    'melon': {
      Season.spring: 1.4,
      Season.summer: 0.7,
      Season.autumn: 1.3,
      Season.winter: 2.0,
    },

    // VERDURAS
    'tomate': {
      Season.spring: 0.9,
      Season.summer: 0.7,
      Season.autumn: 0.8,
      Season.winter: 1.3,
    },
    'calabaza': {
      Season.spring: 1.3,
      Season.summer: 1.4,
      Season.autumn: 0.7,
      Season.winter: 0.9,
    },
    'esparrago': {
      Season.spring: 0.7,
      Season.summer: 1.4,
      Season.autumn: 1.5,
      Season.winter: 1.6,
    },
    'alcachofa': {
      Season.spring: 0.8,
      Season.summer: 1.5,
      Season.autumn: 0.9,
      Season.winter: 0.7,
    },
    'berenjena': {
      Season.spring: 1.2,
      Season.summer: 0.7,
      Season.autumn: 0.9,
      Season.winter: 1.4,
    },
    'calabacin': {
      Season.spring: 0.9,
      Season.summer: 0.7,
      Season.autumn: 0.8,
      Season.winter: 1.3,
    },
  };

  /// Obtiene la estación actual
  static Season getCurrentSeason([DateTime? date]) {
    final m = (date ?? DateTime.now()).month;
    if (m >= 3 && m <= 5) return Season.spring;
    if (m >= 6 && m <= 8) return Season.summer;
    if (m >= 9 && m <= 11) return Season.autumn;
    return Season.winter;
  }

  /// Obtiene el multiplicador estacional para un ingrediente
  static double getSeasonalMultiplier(String ingredientName, [DateTime? date]) {
    final normalizedName = SmartIngredientNormalizer().normalize(ingredientName);
    final season = getCurrentSeason(date);

    // Buscar coincidencia exacta
    if (_seasonalMultipliers.containsKey(normalizedName)) {
      return _seasonalMultipliers[normalizedName]![season]!;
    }

    // Buscar coincidencia fuzzy
    final bestMatch = SmartIngredientNormalizer.findBestMatch(
      normalizedName,
      _seasonalMultipliers.keys.toList(),
      minScore: 85,
    );

    if (bestMatch != null) {
      return _seasonalMultipliers[bestMatch]![season]!;
    }

    // Sin datos estacionales, sin cambio
    return 1.0;
  }

  /// Aplica ajuste estacional a un precio
  static double applySeasonalAdjustment(
    double basePrice,
    String ingredientName, [
    DateTime? date,
  ]) {
    return basePrice * getSeasonalMultiplier(ingredientName, date);
  }
}