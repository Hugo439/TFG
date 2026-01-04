import 'package:smartmeal/domain/value_objects/shopping_item_category.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

/// Servicio para auto-categorizar ingredientes usando fuzzy matching.
///
/// Responsabilidades:
/// - Determinar categoría automática de un ingrediente
/// - Usar base de datos de palabras clave por categoría
/// - Aplicar fuzzy matching (tokenSetRatio) para matching parcial
///
/// Categorías soportadas:
/// - **lacteos**: queso, yogur, leche, mantequilla, nata, etc.
/// - **carnesYPescados**: pollo, pavo, cerdo, salmón, atún, gambas, etc.
/// - **frutasYVerduras**: manzana, tomate, lechuga, zanahoria, aguacate, etc.
/// - **panaderia**: pan, baguette, tortilla, tostada, granola, etc.
/// - **bebidas**: agua, zumo, café, té, refresco, etc.
/// - **snacks**: almendra, nuez, chocolate, galleta, barrita, etc.
/// - **otros**: arroz, pasta, aceite, especias, legumbres (fallback)
///
/// Algoritmo:
/// 1. Para cada categoría, evaluar todas las palabras clave
/// 2. Usar tokenSetRatio para comparar ingrediente con palabra clave
/// 3. Mantener mejor score y categoría correspondiente
/// 4. Si score >= 100 (match perfecto), retornar inmediatamente
/// 5. Si mejor score > 50, retornar categoría; sino, retornar 'otros'
///
/// Ejemplos:
/// ```dart
/// guessCategory("pechuga de pollo") → carnesYPescados (match con "pollo")
/// guessCategory("tomate cherry") → frutasYVerduras (match con "tomate")
/// guessCategory("leche de almendras") → lacteos (match con "leche almendras")
/// guessCategory("pasta integral") → otros (match con "pasta")
/// guessCategory("salsa misteriosa") → otros (score bajo, fallback)
/// ```
///
/// Ventajas del fuzzy matching:
/// - Tolera variaciones: "pollo asado", "pechuga pollo", "muslo de pollo" → carnesYPescados
/// - Maneja plurales: "tomates" match con "tomate"
/// - Robusto a descriptores: "aceite oliva virgen extra" match con "aceite"
class SmartCategoryHelper {
  /// Base de datos de categorías por palabra clave
  static const _categoryKeywords = {
    ShoppingItemCategory.lacteos: [
      'queso',
      'yogur',
      'leche',
      'mantequilla',
      'nata',
      'requeson',
      'cottage',
      'mozzarella',
      'parmesano',
      'feta',
      'crema',
      'leche almendras',
      'leche coco',
      'leche soja',
      'leche avena',
    ],
    ShoppingItemCategory.carnesYPescados: [
      'pollo', 'pavo', 'carne', 'cerdo', 'salmon', 'atun', 'merluza', 'bacalao',
      'gambas', 'langostinos', 'res', 'ternera', 'cordero', 'chorizo', 'bacon',
      'filete', 'pechuga', 'muslo', 'jamon',
      // Pescados adicionales para mejorar la clasificación
      'pescado', 'pescado blanco', 'lubina', 'dorada', 'tilapia', 'caballa',
      'sardina', 'boqueron', 'trucha', 'rape', 'calamar', 'sepia', 'pulpo',
    ],
    ShoppingItemCategory.frutasYVerduras: [
      'manzana',
      'platano',
      'naranja',
      'kiwi',
      'pera',
      'fresa',
      'frambuesa',
      'arandano',
      'mango',
      'melocoton',
      'uva',
      'sandia',
      'melon',
      'aguacate',
      'limon',
      'lima',
      'tomate',
      'cebolla',
      'lechuga',
      'espinaca',
      'brocoli',
      'coliflor',
      'zanahoria',
      'pepino',
      'pimiento',
      'calabacin',
      'berenjena',
      'patata',
      'boniato',
      'batata',
      'champiñon',
      'seta',
      'apio',
      'calabaza',
      'esparrag',
      'judias',
      'frutos rojos',
      'alcachofa',
      'puerro',
      'remolacha',
      'pina',
      'alcaparra',
    ],
    ShoppingItemCategory.panaderia: [
      'pan',
      'baguette',
      'hogaza',
      'tortilla',
      'tostada',
      'granola',
      'muesli',
      'masa pizza',
      'croissant',
      'pan dulce',
    ],
    ShoppingItemCategory.bebidas: [
      'agua',
      'zumo',
      'cafe',
      'te',
      'infusion',
      'refresco',
      'batido',
      'caldo',
      'cerveza',
      'vino',
      'licor',
      'bebida',
      'jugo',
    ],
    ShoppingItemCategory.snacks: [
      'almendra',
      'nuez',
      'anacardo',
      'pistacho',
      'cacahuete',
      'pasa',
      'datil',
      'chocolate',
      'galleta',
      'barrita',
      'cereal',
      'granola',
      'chip',
      'palomita',
      'frutos secos',
    ],
    ShoppingItemCategory.otros: [
      'arroz',
      'quinoa',
      'pasta',
      'cuscus',
      'lenteja',
      'garbanzo',
      'frijol',
      'aceite',
      'vinagre',
      'salsa',
      'especias',
      'sal',
      'pimienta',
      'proteina',
      'miel',
      'sirope',
      'pesto',
      'hummus',
      'tofu',
      'avena',
      'comino',
      'cilantro',
      'perejil',
      'oregano',
      'canela',
      'laurel',
      'jengibre',
      'mostaza',
      'tahini',
      'falafel',
      'edamame',
      'semilla',
      'chia',
      'mantequilla',
      'noodle',
      'claras huevo',
      'claras de huevo',
      'clara de huevo',
      'huevo',
    ],
  };

  /// Determina categoría de un ingrediente usando fuzzy matching.
  ///
  /// [ingredientName] - Nombre del ingrediente (puede incluir descriptores).
  ///
  /// Returns: ShoppingItemCategory más apropiada.
  ///
  /// Criterios:
  /// - Score >= 100: match perfecto, retorna inmediatamente
  /// - Score > 50: match aceptable, retorna mejor categoría
  /// - Score <= 50: no match confiable, retorna 'otros' (fallback)
  ///
  /// Nota: Convierte a lowercase antes de comparar.
  ShoppingItemCategory guessCategory(String ingredientName) {
    final n = ingredientName.toLowerCase();

    double bestScore = 0;
    ShoppingItemCategory bestCategory = ShoppingItemCategory.otros;

    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        final score = tokenSetRatio(n, keyword).toDouble();

        if (score > bestScore) {
          bestScore = score;
          bestCategory = entry.key;

          if (score >= 100) {
            return bestCategory;
          }
        }
      }
    }

    return bestScore > 50 ? bestCategory : ShoppingItemCategory.otros;
  }
}
