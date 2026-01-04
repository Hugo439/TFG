/// Servicio para ajustar precios según variantes del producto.
///
/// Responsabilidades:
/// - Detectar variantes de productos en nombre de ingrediente
/// - Aplicar multiplicadores de precio según variante
///
/// Variantes soportadas y multiplicadores:
/// - **Bio/Ecológico/Orgánico**: +20% (×1.20)
/// - **Congelado**: -10% (×0.90)
/// - **Fresco**: +5% (×1.05)
/// - **Sin lactosa/gluten**: +15% (×1.15)
/// - **Desnatado/Light**: -5% (×0.95)
/// - **Premium/Gourmet/Ibérico/Corral**: +30% (×1.30)
///
/// Ejemplos:
/// ```dart
/// getVariantMultiplier("leche ecológica") → 1.20
/// getVariantMultiplier("pollo congelado") → 0.90
/// getVariantMultiplier("jamón ibérico") → 1.30
/// getVariantMultiplier("yogur light") → 0.95
/// getVariantMultiplier("tomate") → 1.0 (sin variante)
/// ```
///
/// Uso típico:
/// ```dart
/// final basePrice = 5.0;
/// final multiplier = VariantAdjustmentService.getVariantMultiplier("queso bio");
/// final adjustedPrice = basePrice * multiplier; // 5.0 * 1.20 = 6.0
/// ```
///
/// Nota: Detecta múltiples keywords, pero solo aplica el primer multiplicador encontrado.
/// El orden de prioridad está en el código (bio > congelado > fresco > sin alérgenos > light > premium).
class VariantAdjustmentService {
  /// Obtiene multiplicador de precio según variantes detectadas.
  ///
  /// [ingredientName] - Nombre del ingrediente (puede incluir descriptores).
  ///
  /// Returns: Multiplicador de precio (0.90 a 1.30), 1.0 si sin variante.
  ///
  /// Detección:
  /// - Convierte a lowercase
  /// - Busca keywords de variantes
  /// - Retorna multiplicador del primer match encontrado
  /// - Prioridad: bio > congelado > fresco > sin alérgeno > light > premium
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

  /// Lista variantes detectadas en nombre de ingrediente.
  ///
  /// [ingredientName] - Nombre del ingrediente.
  ///
  /// Returns: Lista de strings descriptivos de variantes con multiplicador.
  ///
  /// Ejemplo:
  /// ```dart
  /// detectVariants("leche ecológica fresca")
  ///  ["Ecológico (+20%)", "Fresco (+5%)"]
  /// ```
  ///
  /// Útil para mostrar al usuario qué ajustes se aplicaron.
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
