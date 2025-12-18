/// Servicio para ajustes de precio según variantes
class VariantAdjustmentService {
  /// Detecta y calcula ajuste según variantes del producto
  static double getVariantMultiplier(String ingredientName) {
    final name = ingredientName.toLowerCase();

    // Bio/Ecológico: +20%
    if (name.contains('bio') ||
        name.contains('ecológico') ||
        name.contains('ecologico') ||
        name.contains('orgánico') ||
        name.contains('organico')) {
      return 1.20;
    }

    // Congelado: -10%
    if (name.contains('congelado') || name.contains('frozen')) {
      return 0.90;
    }

    // Fresco: +5%
    if (name.contains('fresco') || name.contains('fresh')) {
      return 1.05;
    }

    // Sin lactosa/gluten: +15%
    if (name.contains('sin lactosa') ||
        name.contains('sin gluten') ||
        name.contains('lactose free') ||
        name.contains('gluten free')) {
      return 1.15;
    }

    // Desnatado/Light: -5%
    if (name.contains('desnatado') ||
        name.contains('light') ||
        name.contains('bajo en grasa')) {
      return 0.95;
    }

    // Premium/Gourmet: +30%
    if (name.contains('premium') ||
        name.contains('gourmet') ||
        name.contains('ibérico') ||
        name.contains('iberico') ||
        name.contains('corral')) {
      return 1.30;
    }

    // Sin variante especial
    return 1.0;
  }

  /// Lista variantes detectadas
  static List<String> detectVariants(String ingredientName) {
    final name = ingredientName.toLowerCase();
    final variants = <String>[];

    if (name.contains('bio') ||
        name.contains('ecológico') ||
        name.contains('ecologico')) {
      variants.add('Ecológico (+20%)');
    }
    if (name.contains('congela')) {
      // "congelado", "congelada", "congeladas", etc.
      variants.add('Congelado (-10%)');
    }
    if (name.contains('fresco') || name.contains('fresca')) {
      variants.add('Fresco (+5%)');
    }
    if (name.contains('sin lactosa') || name.contains('sin gluten')) {
      variants.add('Sin alérgeno (+15%)');
    }
    if (name.contains('desnatado') || name.contains('light')) {
      variants.add('Light (-5%)');
    }
    if (name.contains('premium') ||
        name.contains('gourmet') ||
        name.contains('ibérico')) {
      variants.add('Premium (+30%)');
    }

    return variants;
  }
}
