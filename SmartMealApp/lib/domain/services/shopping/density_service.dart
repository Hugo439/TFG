import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// Servicio para conversión de densidades
class DensityService {
  /// Densidades aproximadas (g/ml)
  static const Map<String, double> _densities = {
    'aceite': 0.92,
    'aceite oliva': 0.92,
    'aceite girasol': 0.92,
    'vinagre': 1.01,
    'leche': 1.03,
    'agua': 1.00,
    'miel': 1.42,
    'melaza': 1.45,
    'sirope': 1.37,
    'zumo': 1.04,
    'caldo': 1.00,
    'salsa tomate': 1.10,
    'yogur': 1.05,
    'nata': 1.01,
    'vino': 0.99,
  };

  /// Obtiene densidad para conversión peso↔volumen
  static double? getDensity(String ingredientName) {
    final name = ingredientName.toLowerCase();

    for (final entry in _densities.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Convierte volumen (ml) a peso (g) si es posible
  static double? volumeToWeight(double volumeMl, String ingredientName) {
    final density = getDensity(ingredientName);
    if (density == null) return null;
    return volumeMl * density;
  }

  /// Convierte peso (g) a volumen (ml) si es posible
  static double? weightToVolume(double weightG, String ingredientName) {
    final density = getDensity(ingredientName);
    if (density == null) return null;
    return weightG / density;
  }

  /// Determina si un ingrediente debería usar volumen en lugar de peso
  static UnitKind suggestUnitKind(String ingredientName) {
    final name = ingredientName.toLowerCase().trim();

    // Unidades contables (check first to avoid conflicts like "agua" in "aguacate")
    if (name.contains('huevo') ||
        name.contains('aguacate') ||
        name.contains('tortilla') ||
        name.contains('pan')) {
      return UnitKind.unit;
    }

    // Líquidos
    if (name.contains('aceite') ||
        name.contains('leche') ||
        (name.contains('agua') && !name.contains('aguacate')) ||
        name.contains('zumo') ||
        name.contains('caldo') ||
        name.contains('vinagre') ||
        name.contains('vino') ||
        name.contains('bebida')) {
      return UnitKind.volume;
    }

    // Por defecto: peso
    return UnitKind.weight;
  }
}
