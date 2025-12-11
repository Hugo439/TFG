import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class SmartIngredientNormalizer {
  // Palabras de ruido
  static const _noiseWords = {
    'virgen', 'extra', 'ecologico', 'ecologicos', 'ecológico', 'ecológicos', 
    'bio', 'organico', 'organicos', 'orgánico', 'orgánicos',
    'fresco', 'frescos', 'congelado', 'congelados', 'natural', 'naturales', 'light',
    'sin', 'lactosa', 'desnatado', 'semidesnatado',
    'de', 'corral', 'campero', 'iberico', 'ibérico',
    'troceado', 'fileteado', 'rodajas', 'rebanadas',
    'kg', 'g', 'gr', 'ml', 'l', 'ud', 'uds', 'unidad', 'unidades',
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
    'porotos': 'alubia',
    'frijoles': 'alubia',
    'judias': 'alubia',
    'judia': 'alubia',
    'acelgas': 'acelga',
    'papas': 'patata',
    'camote': 'batata',
    'boniato': 'batata',
    'porridge': 'avena',
    'pechuga pollo': 'pollo',
  };

  /// Normaliza un ingrediente
  String normalize(String raw) {
    var s = raw.toLowerCase().trim();
    if (s.isEmpty) return '';
    
    s = _stripAccents(s);
    s = _convertPluralToSingular(s); // Hacer primero plural→singular
    s = _replaceSynonyms(s);
    s = _removeStopWords(s);
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  String _stripAccents(String s) {
    const withAccents = 'áéíóúüñç';
    const without =    'aeiouunc';
    for (var i = 0; i < withAccents.length; i++) {
      s = s.replaceAll(withAccents[i], without[i]);
    }
    return s;
  }

  String _removeStopWords(String s) {
    for (final w in _noiseWords) {
      s = s.replaceAll(RegExp('\\b$w\\b'), '');
    }
    return s;
  }

  String _convertPluralToSingular(String s) {
    for (final e in _pluralSingularMap.entries) {
      s = s.replaceAll(RegExp('\\b${e.key}\\b'), e.value);
    }
    return s;
  }

  String _replaceSynonyms(String s) {
    for (final e in _synonyms.entries) {
      s = s.replaceAll(RegExp('\\b${e.key}\\b'), e.value);
    }
    return s;
  }

  /// Fuzzy: mejor coincidencia en candidatos
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
      normalizedCandidate = normalizer._convertPluralToSingular(normalizedCandidate);
      normalizedCandidate = normalizedCandidate.replaceAll(RegExp(r'\s+'), ' ').trim();
      
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
