import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class SmartIngredientNormalizer {
  /// Palabras que se ignoran
  static const _stopWords = {
    'de', 'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas',
    'para', 'por', 'con', 'sin', 'en', 'del', 'al',
    'seco', 'secas', 'cocido', 'cocida', 'cocidos', 'cocidas',
    'fresco', 'fresca', 'frescos', 'frescas',
    'ligero', 'ligera', 'ligeros', 'ligeras',
    'natural', 'naturales',
    'integral', 'integrales',
    'virgen', 'extra', 'light',
    'bajo', 'baja', 'bajos', 'bajas',
    'grasa', 'sodio', 'azucar', 'azúcar',
    'grande', 'pequeño', 'medianos',
    'colores', 'variados', 'variadas',
    'crudo', 'asado', 'frito', 'hervido',
    'rallado', 'molido', 'triturado', 'picado',
    'sabor', 'vainilla', 'neutro',
  };

  /// Normalizador de base de datos de ingredientes conocidos
  static const _baseIngredients = {
    // Huevos
    'huevo': ['huevo', 'clara', 'yema', 'huevo clara'],
    
    // Aceites
    'aceite oliva': ['aceite oliva', 'aceite de oliva virgen', 'aceite de oliva extra'],
    'aceite sesamo': ['aceite sesamo', 'aceite de sesamo'],
    'aceite coco': ['aceite coco', 'aceite de coco'],
    
    // Quesos
    'queso': ['queso', 'queso rallado', 'queso crema'],
    'queso fresco': ['queso fresco'],
    'feta': ['feta', 'queso feta'],
    'queso parmesano': ['queso parmesano', 'parmesano rallado'],
    'queso mozzarella': ['queso mozzarella', 'mozarella', 'mozzarella'],
    'queso cottage': ['queso cottage', 'cottage'],
    'requeson': ['requeson', 'requesón'],
    
    // Leches
    'leche': ['leche', 'leche entera', 'leche desnatada'],
    'leche almendras': ['leche almendras', 'leche de almendras'],
    'leche coco': ['leche coco', 'leche de coco'],
    'leche soja': ['leche soja', 'leche de soja'],
    'leche avena': ['leche avena', 'leche de avena'],
    
    // Yogures
    'yogur': ['yogur', 'yogur griego', 'yogur natural'],
    
    // Arroces
    'arroz': ['arroz blanco', 'arroz'],
    'arroz integral': ['arroz integral'],
    'arroz basmati': ['arroz basmati'],
    
    // Pastas
    'pasta': ['pasta', 'pasta seca'],
    'pasta integral': ['pasta integral'],
    'noodles arroz': ['noodles arroz', 'noodles de arroz'],
    
    // Legumbres
    'lentejas': ['lentejas', 'lentejas rojas', 'lentejas verdes', 'lentejas pardinas'],
    'garbanzos': ['garbanzos', 'garbanzos cocidos'],
    'frijol negro': ['frijol negro', 'frijoles negros'],
    'judias verdes': ['judias verdes', 'judías verdes'],
    
    // Frutas
    'manzana': ['manzana'],
    'platano': ['platano', 'banana'],
    'pera': ['pera'],
    'arandano': ['arandano', 'arandanos'],
    'fresa': ['fresa', 'fresas'],
    'frambuesa': ['frambuesa', 'frambuesas'],
    'frutos rojos': ['frutos rojos', 'frutos rojos variados'],
    'kiwi': ['kiwi'],
    'naranja': ['naranja'],
    'limon': ['limon', 'limón'],
    'mango': ['mango'],
    
    // Verduras
    'tomate': ['tomate', 'tomate cherry', 'tomate triturado'],
    'cebolla': ['cebolla'],
    'lechuga': ['lechuga', 'mezcla de lechugas'],
    'espinaca': ['espinaca', 'espinacas'],
    'brocoli': ['brocoli', 'brócoli'],
    'coliflor': ['coliflor'],
    'zanahoria': ['zanahoria', 'zanahorias'],
    'pepino': ['pepino'],
    'pimiento': ['pimiento', 'pimiento rojo', 'pimiento verde'],
    'calabacin': ['calabacin', 'calabacín'],
    'berenjena': ['berenjena'],
    'patata': ['patata', 'papa'],
    'batata': ['batata'],
    'boniato': ['boniato'],
    'calabaza': ['calabaza'],
    'apio': ['apio'],
    'champiñon': ['champiñon', 'champiñones', 'seta'],
    'espárrago': ['espárrago', 'espárragos'],
    'edamame': ['edamame'],
    
    // Carnes
    'pollo': ['pollo', 'pechuga pollo', 'muslo pollo'],
    'pavo': ['pavo'],
    'carne res': ['carne res', 'carne molida'],
    'cerdo': ['cerdo', 'lomo cerdo'],
    'chorizo': ['chorizo'],
    'bacon': ['bacon'],
    
    // Pescados
    'salmon': ['salmon', 'salmón'],
    'merluza': ['merluza', 'filete merluza'],
    'bacalao': ['bacalao'],
    'atun': ['atun', 'atún'],
    'gambas': ['gambas', 'gambas peladas'],
    'langostinos': ['langostinos'],
    
    // Frutos secos
    'almendra': ['almendra', 'almendras'],
    'nuez': ['nuez', 'nueces'],
    'anacardo': ['anacardo', 'anacardos'],
    'pistacho': ['pistacho', 'pistachos'],
    'pasa': ['pasa', 'pasas'],
    
    // Semillas
    'semillas chia': ['semillas chia', 'chia'],
    'semillas girasol': ['semillas girasol', 'pipas girasol'],
    'semillas calabaza': ['semillas calabaza', 'pipas calabaza'],
    
    // Otros
    'miel': ['miel'],
    'sirope arce': ['sirope arce', 'sirope maple'],
    'sal': ['sal'],
    'pimienta': ['pimienta'],
    'comino': ['comino'],
    'cilantro': ['cilantro'],
    'perejil': ['perejil'],
    'oregano': ['oregano', 'orégano'],
    'canela': ['canela'],
    'laurel': ['laurel'],
    'jengibre': ['jengibre'],
    'vinagre': ['vinagre', 'vinagre balsamico', 'vinagre blanco'],
    'salsa soja': ['salsa soja', 'salsa de soja', 'tamari'],
    'mostaza': ['mostaza'],
    'pesto': ['pesto', 'pesto de albahaca'],
    'hummus': ['hummus'],
    'tofu': ['tofu'],
    'tempeh': ['tempeh'],
    'avena': ['avena', 'copos avena'],
    'quinoa': ['quinoa'],
    'cuscus': ['cuscus', 'cuscús'],
    'pan': ['pan', 'pan integral', 'pan hamburguesa'],
    'tortilla': ['tortilla', 'tortilla maiz', 'tortilla trigo'],
    'granola': ['granola'],
    'mantequilla cacahuete': ['mantequilla cacahuete', 'crema cacahuete'],
    'mantequilla almendras': ['mantequilla almendras'],
    'falafel': ['falafel'],
    'salsa tahini': ['salsa tahini', 'tahini'],
    'pasta curry': ['pasta curry', 'pasta de curry'],
  };

  /// Mapa de plural a singular 
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
    'lentejas': 'lentejas',
    'garbanzos': 'garbanzos',
    'espinacas': 'espinaca',
    'champiñones': 'champiñon',
    'esparragos': 'espárrago',
    'fresas': 'fresa',
    'frambuesas': 'frambuesa',
    'arandanos': 'arandano',
  };

  /// Normaliza un ingrediente
  String normalize(String raw) {
    var s = raw.toLowerCase().trim();
    s = _stripAccents(s);
    s = _removeStopWords(s);
    s = _convertPluralToSingular(s);
    s = s.trim();

    // Buscar coincidencia fuzzy en la base de datos
    final normalized = _findBestMatch(s);
    return normalized.isEmpty ? raw.toLowerCase().trim() : normalized;
  }

  /// Convierte plural a singular
  String _convertPluralToSingular(String text) {
    for (final entry in _pluralSingularMap.entries) {
      text = text.replaceAll(RegExp('\\b${entry.key}\\b'), entry.value);
    }
    return text;
  }

  /// Encuentra la mejor coincidencia usando fuzzy matching
  String _findBestMatch(String input) {
    double bestScore = 0;
    String bestMatch = '';

    for (final ingredient in _baseIngredients.keys) {
      final variants = _baseIngredients[ingredient]!;
      
      for (final variant in variants) {
        // Usa token_set_ratio para mejor matching
        final score = tokenSetRatio(input, variant).toDouble();
        
        if (score > bestScore) {
          bestScore = score;
          bestMatch = ingredient;
        }
      }
    }

    // Si la similitud es mayor al 70%, usar la coincidencia encontrada
    return bestScore > 70 ? bestMatch : '';
  }

  /// Elimina palabras comunes
  String _removeStopWords(String text) {
    final words = text.split(RegExp(r'\s+'));
    final filtered = words.where((w) => !_stopWords.contains(w));
    return filtered.join(' ');
  }

  /// Elimina tildes
  String _stripAccents(String text) {
    const withAccent = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const without = 'aaaaaeeeeiiiiooooouuuunc';
    var result = text;
    
    for (int i = 0; i < withAccent.length; i++) {
      result = result.replaceAll(withAccent[i], without[i]);
    }
    return result;
  }

  /// Encuentra el mejor match en una lista de candidatos
  static String? findBestMatch(
    String input,
    List<String> candidates, {
    int minScore = 70,
  }) {
    final normalizer = SmartIngredientNormalizer();
    final normalizedInput = normalizer.normalize(input);

    int bestScore = 0;
    String? bestMatch;

    for (final candidate in candidates) {
      final normalizedCandidate = normalizer.normalize(candidate);
      
      final score = tokenSetRatio(normalizedInput, normalizedCandidate);

      if (score > bestScore && score >= minScore) {
        bestScore = score;
        bestMatch = candidate;
      }
    }

    return bestMatch;
  }

  /// Calcula similitud entre dos ingredientes (0-100)
  static int similarity(String a, String b) {
    final normalizer = SmartIngredientNormalizer();
    return tokenSetRatio(normalizer.normalize(a), normalizer.normalize(b));
  }
}