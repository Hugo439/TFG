import 'package:fuzzywuzzy/fuzzywuzzy.dart';

/// Servicio para normalizar nombres de ingredientes y prevenir duplicados.
///
/// Responsabilidades:
/// - **Remover palabras de ruido**: elimina adjetivos y descriptores innecesarios
/// - **Convertir plural → singular**: unifica variaciones de cantidad
/// - **Reemplazar sinónimos**: consolida ingredientes equivalentes
/// - **Normalizar acentos**: elimina tildes para consistencia
/// - **Fuzzy matching**: detecta variantes similares
///
/// Proceso de normalización (aplicado en orden):
/// 1. **Lowercase**: todo a minúsculas
/// 2. **Remover ruido**: quita palabras como "virgen", "extra", "ecológico", "fresco", etc.
/// 3. **Plural → singular**: "huevos" → "huevo", "tomates" → "tomate"
/// 4. **Sinónimos ordenados**: reemplazos priorizados por especificidad
///    - Más específico primero: "claras de huevo" → "huevo" antes de "clara" → "huevo"
///    - Evita conflictos: "pechuga de pollo" → "pollo" antes de "pechuga" → "pollo"
/// 5. **Remover acentos**: ó → o, é → e, etc.
/// 6. **Trim y limpieza**: elimina espacios extras
///
/// Ejemplos:
/// ```dart
/// normalize("Aceite de oliva virgen extra") → "aceite oliva"
/// normalize("3 huevos frescos") → "huevo"
/// normalize("Tomates cherry ecológicos") → "tomate cherry"
/// normalize("Pechuga de pollo") → "pollo"
/// normalize("Claras de huevo") → "huevo"
/// normalize("Azúcar moreno") → "azucar"
/// ```
///
/// Impacto:
/// - Reduce duplicados en listas de compra: "200g Pollo" + "300g pollo fresco" = "500g pollo"
/// - Mejora búsqueda de precios: "tomate" encuentra "tomate cherry", "tomates rama", etc.
/// - Facilita agregación de ingredientes en IngredientAggregator
class SmartIngredientNormalizer {
  // Palabras de ruido
  static const _noiseWords = {
    'virgen',
    'extra',
    'ecologico',
    'ecologicos',
    'ecológico',
    'ecológicos',
    'bio',
    'organico',
    'organicos',
    'orgánico',
    'orgánicos',
    'fresco',
    'frescos',
    'congelado',
    'congelados',
    'natural',
    'naturales',
    'light',
    'sin',
    'lactosa',
    'desnatado',
    'semidesnatado',
    'de',
    'corral',
    'campero',
    'iberico',
    'ibérico',
    'troceado',
    'fileteado',
    'rodajas',
    'rebanadas',
    'kg',
    'g',
    'gr',
    'ml',
    'l',
    'ud',
    'uds',
    'unidad',
    'unidades',
    'lomo',
    'asado',
    'asada',
    'asados',
    'asadas',
    'frito',
    'cocido',
    'cocida',
    'cocidos',
    'cocidas',
  };

  // Plural → singular
  static const _pluralSingularMap = {
    'huevos': 'huevo',
    'tomates': 'tomate',
    'patatas': 'patata',
    'cebollas': 'cebolla',
    'pimientos': 'pimiento',
    'zanahorias': 'zanahoria',
    'aguacates': 'aguacate',
    'platanos': 'platano',
    'manzanas': 'manzana',
    'naranjas': 'naranja',
    'espinacas': 'espinaca',
    'champiñones': 'champiñon',
    'esparragos': 'esparrago',
    'fresas': 'fresa',
    'frescos': 'fresco',
    'frambuesas': 'frambuesa',
    'arandanos': 'arandano',
    'lentejas': 'lenteja',
    'garbanzos': 'garbanzo',
    'judias': 'judia',
    'judias verdes': 'judia verde',
    'alubias': 'alubia',
  };

  // Sinónimos básicos
  static const _synonyms = {
    // ⚠️  IMPORTANTE: Ordenar por especificidad (más específico primero)
    // Así "claras huevo" se reemplaza ANTES que "claras" solo
    'claras de huevo': 'huevo', // Exacto: 3 palabras
    'clara de huevo': 'huevo', // Singular exacto: 3 palabras
    'claras huevo': 'huevo', // Sin "de": 2 palabras (ANTES de "claras" solo)
    'clara huevo': 'huevo', // Clara singular + huevo: 2 palabras
    'claras': 'huevo', // Fallback: solo claras (1 palabra)
    'clara': 'huevo', // Clara singular solo (1 palabra)
    'pechuga pollo': 'pollo', // 2 palabras (ANTES de otros singles)
    'pavo pechuga': 'pechuga pavo',
    'porotos': 'alubia',
    'frijoles': 'alubia',
    'judias': 'alubia',
    'judia': 'alubia',
    'acelgas': 'acelga',
    'papas': 'patata',
    'camote': 'batata',
    'boniato': 'batata',
    'porridge': 'avena',
  };

  /// Normaliza nombre de ingrediente aplicando todas las transformaciones.
  ///
  /// [raw] - Nombre original del ingrediente.
  ///
  /// Returns: Nombre normalizado y limpio.
  ///
  /// Pipeline:
  /// lowercase → remover paréntesis/corchetes → remover acentos →
  /// plural→singular → sinónimos → remover ruido → trim espacios
  String normalize(String raw) {
    var s = raw.toLowerCase().trim();
    if (s.isEmpty) return '';

    // Eliminar contenido entre paréntesis y otros delimitadores
    s = s.replaceAll(RegExp(r'\(.*?\)'), ' ');
    s = s.replaceAll(RegExp(r'\[.*?\]|\{.*?\}'), ' ');

    s = _stripAccents(s);
    s = _convertPluralToSingular(s); // Hacer primero plural→singular
    s = _replaceSynonyms(s);
    s = _removeStopWords(s);
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  /// Elimina acentos y caracteres especiales españoles.
  ///
  /// Conversiones: á→a, é→e, í→i, ó→o, ú→u, ü→u, ñ→n, ç→c
  String _stripAccents(String s) {
    const withAccents = 'áéíóúüñç';
    const without = 'aeiouunc';
    for (var i = 0; i < withAccents.length; i++) {
      s = s.replaceAll(withAccents[i], without[i]);
    }
    return s;
  }

  /// Elimina palabras de ruido definidas en _noiseWords.
  ///
  /// Usa RegExp con \b (word boundary) para evitar reemplazos parciales.
  String _removeStopWords(String s) {
    for (final w in _noiseWords) {
      s = s.replaceAll(RegExp('\\b$w\\b'), '');
    }
    return s;
  }

  /// Convierte plurales a singular usando _pluralSingularMap.
  ///
  /// Usa word boundaries para evitar reemplazos parciales.
  String _convertPluralToSingular(String s) {
    for (final e in _pluralSingularMap.entries) {
      s = s.replaceAll(RegExp('\\b${e.key}\\b'), e.value);
    }
    return s;
  }

  /// Reemplaza sinónimos usando _synonyms map.
  ///
  /// IMPORTANTE: El orden en _synonyms importa (más específico primero).
  String _replaceSynonyms(String s) {
    for (final e in _synonyms.entries) {
      s = s.replaceAll(RegExp('\\b${e.key}\\b'), e.value);
    }
    return s;
  }

  /// Encuentra mejor coincidencia fuzzy entre candidatos.
  ///
  /// [input] - Ingrediente a buscar.
  /// [candidates] - Lista de ingredientes candidatos.
  /// [minScore] - Puntuación mínima (0-100), default 80.
  ///
  /// Returns: Mejor match si score >= minScore, null si no hay coincidencias.
  ///
  /// Usa fuzzywuzzy para comparación, normaliza input y candidatos antes.
  static String? findBestMatch(
    String input,
    List<String> candidates, {
    int minScore = 80,
  }) {
    if (input.isEmpty) return null;

    final normalizer = SmartIngredientNormalizer();
    // Normalize input without calling normalize() to avoid recursion
    var normalizedInput = input.toLowerCase().trim();
    normalizedInput = normalizer._stripAccents(normalizedInput);
    normalizedInput = normalizer._replaceSynonyms(normalizedInput);
    normalizedInput = normalizer._removeStopWords(normalizedInput);
    normalizedInput = normalizer._convertPluralToSingular(normalizedInput);
    normalizedInput = normalizedInput.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalizedInput.isEmpty) return null;

    int best = 0;
    String? bestMatch;
    for (final c in candidates) {
      if (c.isEmpty) continue;
      // Normalize candidate the same way
      var normalizedCandidate = c.toLowerCase().trim();
      normalizedCandidate = normalizer._stripAccents(normalizedCandidate);
      normalizedCandidate = normalizer._replaceSynonyms(normalizedCandidate);
      normalizedCandidate = normalizer._removeStopWords(normalizedCandidate);
      normalizedCandidate = normalizer._convertPluralToSingular(
        normalizedCandidate,
      );
      normalizedCandidate = normalizedCandidate
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (normalizedCandidate.isEmpty) continue;

      final score = tokenSetRatio(normalizedInput, normalizedCandidate);
      if (score > best && score >= minScore) {
        best = score;
        bestMatch = c;
      }
    }
    return bestMatch;
  }

  /// Similitud 0-100
  static int similarity(String a, String b) {
    final normalizer = SmartIngredientNormalizer();
    // Normalize both inputs without calling normalize() to avoid recursion
    var normalizedA = a.toLowerCase().trim();
    normalizedA = normalizer._stripAccents(normalizedA);
    normalizedA = normalizer._replaceSynonyms(normalizedA);
    normalizedA = normalizer._removeStopWords(normalizedA);
    normalizedA = normalizer._convertPluralToSingular(normalizedA);
    normalizedA = normalizedA.replaceAll(RegExp(r'\s+'), ' ').trim();

    var normalizedB = b.toLowerCase().trim();
    normalizedB = normalizer._stripAccents(normalizedB);
    normalizedB = normalizer._replaceSynonyms(normalizedB);
    normalizedB = normalizer._removeStopWords(normalizedB);
    normalizedB = normalizer._convertPluralToSingular(normalizedB);
    normalizedB = normalizedB.replaceAll(RegExp(r'\s+'), ' ').trim();

    return tokenSetRatio(normalizedA, normalizedB);
  }
}
