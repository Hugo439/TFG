import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

/// Enum para las cuatro estaciones del año.
enum Season { spring, summer, autumn, winter }

/// Servicio para ajustar precios de ingredientes según estacionalidad.
///
/// Responsabilidades:
/// - Determinar estación actual según fecha
/// - Aplicar multiplicadores estacionales a precios base
/// - Usar fuzzy matching para ingredientes no exactos
///
/// Lógica estacional:
/// - Ingredientes en temporada: multiplicador < 1.0 (más baratos)
/// - Ingredientes fuera de temporada: multiplicador > 1.0 (más caros)
///
/// Ejemplos de multiplicadores:
/// - **Fresa**: primavera 0.7, verano 0.8, otoño 1.4, invierno 1.5
/// - **Sandía**: primavera 1.3, verano 0.6, otoño 1.4, invierno 2.0
/// - **Naranja**: primavera 1.2, verano 1.5, otoño 0.9, invierno 0.7
/// - **Tomate**: primavera 0.9, verano 0.7, otoño 0.8, invierno 1.3
/// - **Calabaza**: primavera 1.3, verano 1.4, otoño 0.7, invierno 0.9
///
/// Uso típico:
/// ```dart
/// final basePrice = 3.0; // €/kg
/// final adjustedPrice = SeasonalPricingService.applySeasonalAdjustment(
///   basePrice,
///   "fresa",
/// );
/// // En primavera: 3.0 * 0.7 = 2.1 €/kg
/// // En invierno: 3.0 * 1.5 = 4.5 €/kg
/// ```
///
/// Fallback: Si ingrediente no tiene datos estacionales, multiplicador = 1.0 (sin cambio).
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

  /// Determina estación actual según mes.
  ///
  /// [date] - Fecha a evaluar (default: DateTime.now()).
  ///
  /// Returns: Season correspondiente.
  ///
  /// Distribución:
  /// - Primavera: marzo-mayo (meses 3-5)
  /// - Verano: junio-agosto (meses 6-8)
  /// - Otoño: septiembre-noviembre (meses 9-11)
  /// - Invierno: diciembre-febrero (meses 12, 1, 2)
  static Season getCurrentSeason([DateTime? date]) {
    final m = (date ?? DateTime.now()).month;
    if (m >= 3 && m <= 5) return Season.spring;
    if (m >= 6 && m <= 8) return Season.summer;
    if (m >= 9 && m <= 11) return Season.autumn;
    return Season.winter;
  }

  /// Obtiene multiplicador estacional para un ingrediente.
  ///
  /// [ingredientName] - Nombre del ingrediente.
  /// [date] - Fecha para determinar estación (default: ahora).
  ///
  /// Returns: Multiplicador (0.6 a 2.0), 1.0 si sin datos estacionales.
  ///
  /// Algoritmo:
  /// 1. Normalizar nombre con SmartIngredientNormalizer
  /// 2. Buscar coincidencia exacta en _seasonalMultipliers
  /// 3. Si no existe, hacer fuzzy matching (minScore 85)
  /// 4. Si encuentra match, retornar multiplicador de la estación actual
  /// 5. Si no encuentra, retornar 1.0 (sin ajuste)
  static double getSeasonalMultiplier(String ingredientName, [DateTime? date]) {
    final normalizedName = SmartIngredientNormalizer().normalize(
      ingredientName,
    );
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

  /// Aplica ajuste estacional a un precio base.
  ///
  /// [basePrice] - Precio base del ingrediente.
  /// [ingredientName] - Nombre del ingrediente.
  /// [date] - Fecha para determinar estación (default: ahora).
  ///
  /// Returns: Precio ajustado = basePrice × multiplicador estacional.
  ///
  /// Ejemplo:
  /// ```dart
  /// applySeasonalAdjustment(3.0, "fresa", DateTime(2024, 5, 1)) // primavera
  /// // 3.0 * 0.7 = 2.1 €
  /// ```
  static double applySeasonalAdjustment(
    double basePrice,
    String ingredientName, [
    DateTime? date,
  ]) {
    return basePrice * getSeasonalMultiplier(ingredientName, date);
  }
}
