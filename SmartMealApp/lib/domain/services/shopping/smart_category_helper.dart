import 'package:smartmeal/domain/value_objects/shopping_item_category.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class SmartCategoryHelper {
  /// Base de datos de categorías por palabra clave
  static const _categoryKeywords = {
    ShoppingItemCategory.lacteos: [
      'queso', 'yogur', 'leche', 'mantequilla', 'nata', 'huevo', 'requeson',
      'cottage', 'mozzarella', 'parmesano', 'feta', 'crema', 'leche almendras',
      'leche coco', 'leche soja', 'leche avena',
    ],
    ShoppingItemCategory.carnesYPescados: [
      'pollo', 'pavo', 'carne', 'cerdo', 'salmon', 'atun', 'merluza', 'bacalao',
      'gambas', 'langostinos', 'res', 'ternera', 'cordero', 'chorizo', 'bacon',
      'filete', 'pechuga', 'muslo', 'jamon',
    ],
    ShoppingItemCategory.frutasYVerduras: [
      'manzana', 'platano', 'naranja', 'kiwi', 'pera', 'fresa', 'frambuesa',
      'arandano', 'mango', 'melocoton', 'uva', 'sandia', 'melon', 'aguacate',
      'limon', 'lima', 'tomate', 'cebolla', 'lechuga', 'espinaca', 'brocoli',
      'coliflor', 'zanahoria', 'pepino', 'pimiento', 'calabacin', 'berenjena',
      'patata', 'boniato', 'batata', 'champiñon', 'seta', 'apio', 'calabaza',
      'esparrag', 'judias', 'frutos rojos', 'alcachofa', 'puerro', 'remolacha',
    ],
    ShoppingItemCategory.panaderia: [
      'pan', 'baguette', 'hogaza', 'tortilla', 'tostada', 'granola', 'muesli',
      'masa pizza', 'croissant', 'pan dulce',
    ],
    ShoppingItemCategory.bebidas: [
      'agua', 'zumo', 'cafe', 'te', 'infusion', 'refresco', 'batido', 'caldo',
      'cerveza', 'vino', 'licor', 'bebida', 'jugo',
    ],
    ShoppingItemCategory.snacks: [
      'almendra', 'nuez', 'anacardo', 'pistacho', 'cacahuete', 'pasa', 'datil',
      'chocolate', 'galleta', 'barrita', 'cereal', 'granola', 'chip', 'palomita',
    ],
    ShoppingItemCategory.otros: [
      'arroz', 'quinoa', 'pasta', 'cuscus', 'lenteja', 'garbanzo', 'frijol',
      'aceite', 'vinagre', 'salsa', 'especias', 'sal', 'pimienta', 'proteina',
      'miel', 'sirope', 'pesto', 'hummus', 'tofu', 'avena', 'comino', 'cilantro',
      'perejil', 'oregano', 'canela', 'laurel', 'jengibre', 'mostaza', 'tahini',
      'falafel', 'edamame', 'semilla', 'chia', 'mantequilla', 'noodle',
    ],
  };

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