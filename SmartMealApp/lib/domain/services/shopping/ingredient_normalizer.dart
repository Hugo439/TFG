import 'package:characters/characters.dart';

class IngredientNormalizer {
  /// Normaliza un ingrediente ya bien formado:
  /// - Elimina variantes tipográficas menores
  /// - Unifica sinónimos comunes
  /// - Mantiene cantidad y unidad intactas
  String normalize(String raw) {
    var s = raw.toLowerCase().trim();

    // Normalizar tildes
    s = _stripAccents(s);

    // Mapa de sinónimos ligeros (solo variantes reales)
    final map = <String, String>{
      // ===== HUEVOS =====
      'huevo clara': 'huevo',
      'clara huevo': 'huevo',
      'claras huevo': 'huevo',
      'clara de huevo': 'huevo',
      'claras de huevo': 'huevo',
      'clara': 'huevo',
      'claras': 'huevo',
      'yema': 'huevo',
      'yemas': 'huevo',

      // ===== POLLO =====
      'pollo': 'pollo',
      'pollo pechuga': 'pollo',
      'pechuga pollo': 'pollo',
      'muslo pollo': 'pollo',
      'contramuslo': 'pollo',
      'pollo deshuesado': 'pollo',
      'pollo molido': 'pollo',

      // ===== CARNES ROJAS =====
      'carne res': 'carne res',
      'carne molida': 'carne res',
      'carne picada': 'carne res',
      'ternera': 'carne res',
      'lomo res': 'carne res',
      'solomillo res': 'carne res',

      // ===== CERDO =====
      'cerdo': 'cerdo',
      'lomo cerdo': 'cerdo',
      'solomillo cerdo': 'cerdo',
      'costilla cerdo': 'cerdo',

      // ===== PAVO =====
      'pavo': 'pavo',
      'pavo pechuga': 'pavo',
      'pechuga pavo': 'pavo',
      'pavo molido': 'pavo',

      // ===== PESCADOS =====
      'bacalao': 'bacalao',
      'merluza': 'merluza',
      'salmon': 'salmon',
      'salmon fresco': 'salmon',
      'atun': 'atun',
      'trucha': 'trucha',
      'lubina': 'lubina',
      'dorada': 'dorada',
      'pescado blanco': 'pescado blanco',
      'lenguado': 'lenguado',

      // ===== MARISCOS =====
      'gambas': 'gambas',
      'camarones': 'gambas',
      'langostinos': 'langostinos',
      'mejillones': 'mejillones',
      'almejas': 'almejas',
      'vieiras': 'vieiras',

      // ===== VERDURAS =====
      'brocoli': 'brocoli',
      'brocoli al vapor': 'brocoli',
      'coliflor': 'coliflor',
      'calabacin': 'calabacin',
      'calabaza': 'calabaza',
      'berenjena': 'berenjena',
      'pimiento': 'pimiento',
      'pimiento rojo': 'pimiento',
      'pimiento verde': 'pimiento',
      'pimiento amarillo': 'pimiento',
      'tomate': 'tomate',
      'tomate cherry': 'tomate',
      'pepino': 'pepino',
      'lechuga': 'lechuga',
      'espinacas': 'espinacas',
      'acelga': 'acelga',
      'col': 'col',
      'cebolla': 'cebolla',
      'cebolla blanca': 'cebolla',
      'ajo': 'ajo',
      'ajo en polvo': 'ajo',
      'zanahoria': 'zanahoria',
      'patata': 'patata',
      'batata': 'batata',
      'boniato': 'boniato',
      'champiñones': 'champiñones',
      'setas': 'setas',
      'puerro': 'puerro',
      'apio': 'apio',
      'remolacha': 'remolacha',
      'maiz': 'maiz',
      'maiz dulce': 'maiz',
      'elote': 'maiz',
      'judias verdes': 'judias verdes',
      'espárragos': 'espárragos',
      'edamame': 'edamame',

      // ===== LEGUMBRES =====
      'lentejas': 'lentejas',
      'lentejas rojas': 'lentejas rojas',
      'lentejas verdes': 'lentejas verdes',
      'garbanzos': 'garbanzos',
      'judias': 'judias',
      'alubias': 'judias',
      'frijoles': 'judias',
      'porotos': 'judias',
      'soja texturizada': 'soja',
      'tofu': 'tofu',
      'tempeh': 'tempeh',

      // ===== CEREALES/GRANOS =====
      'arroz': 'arroz',
      'arroz integral': 'arroz integral',
      'arroz basmati': 'arroz basmati',
      'arroz salvaje': 'arroz salvaje',
      'arroz blanco': 'arroz blanco',
      'quinoa': 'quinoa',
      'avena': 'avena',
      'pasta': 'pasta',
      'pasta integral': 'pasta',
      'cuscus': 'cuscus',
      'bulgur': 'bulgur',
      'mijo': 'mijo',
      'amaranto': 'amaranto',

      // ===== LÁCTEOS =====
      'leche': 'leche',
      'leche entera': 'leche',
      'leche desnatada': 'leche',
      'leche semi': 'leche',
      'leche de almendras': 'leche almendras',
      'leche almendras': 'leche almendras',
      'leche de coco': 'leche coco',
      'leche coco': 'leche coco',
      'leche de soja': 'leche soja',
      'leche soja': 'leche soja',
      'leche de avena': 'leche avena',
      'leche avena': 'leche avena',
      'yogur': 'yogur',
      'yogur griego': 'yogur griego',
      'yogur natural': 'yogur',
      'queso cottage': 'queso cottage',
      'requeson': 'requeson',
      'queso fresco': 'queso fresco',
      'queso feta': 'feta',
      'feta': 'feta',
      'queso crema': 'queso crema',
      'queso azul': 'queso azul',
      'mozzarella': 'mozarella',
      'mozarella': 'mozarella',
      'parmesano': 'parmesano',
      'queso rallado': 'queso rallado',
      'mantequilla': 'mantequilla',
      'manteca': 'mantequilla',

      // ===== FRUTAS =====
      'manzana': 'manzana',
      'platano': 'platano',
      'banana': 'platano',
      'naranja': 'naranja',
      'limon': 'limon',
      'lima': 'lima',
      'fresa': 'fresa',
      'frambuesa': 'frambuesa',
      'arandano': 'arandano',
      'mora': 'mora',
      'kiwi': 'kiwi',
      'mango': 'mango',
      'papaya': 'papaya',
      'piña': 'piña',
      'pera': 'pera',
      'melocoton': 'melocoton',
      'cereza': 'cereza',
      'uva': 'uva',
      'sandia': 'sandia',
      'melon': 'melon',
      'coco': 'coco',
      'aguacate': 'aguacate',

      // ===== FRUTOS SECAS =====
      'almendras': 'almendras',
      'nueces': 'nueces',
      'anacardos': 'anacardos',
      'cashew': 'anacardos',
      'pistachos': 'pistachos',
      'cacahuetes': 'cacahuetes',
      'dátil': 'datil',
      'dátiles': 'datil',
      'pasas': 'pasas',
      'arándanos secos': 'arandano seco',
      'ciruelas': 'ciruelas',

      // ===== SEMILLAS =====
      'semillas girasol': 'semillas girasol',
      'pipas girasol': 'semillas girasol',
      'semillas calabaza': 'semillas calabaza',
      'pipas calabaza': 'semillas calabaza',
      'semillas sesamo': 'semillas sesamo',
      'semillas chia': 'semillas chia',
      'semillas lino': 'semillas lino',
      'semillas cáñamo': 'semillas cáñamo',

      // ===== GRASAS/ACEITES =====
      'aceite oliva': 'aceite oliva',
      'aceite de oliva': 'aceite oliva',
      'aceite girasol': 'aceite girasol',
      'aceite coco': 'aceite coco',
      'aceite cáñamo': 'aceite cáñamo',
      'mantequilla cacahuete': 'mantequilla cacahuete',
      'mantequilla de cacahuete': 'mantequilla cacahuete',
      'mantequilla almendras': 'mantequilla almendras',
      'tahini': 'tahini',

      // ===== SALSAS/CONDIMENTOS =====
      'salsa soja': 'salsa soja',
      'salsa de soja': 'salsa soja',
      'tamari': 'tamari',
      'vinagre balsamico': 'vinagre balsamico',
      'vinagre blanco': 'vinagre blanco',
      'vinagre arroz': 'vinagre arroz',
      'mostaza': 'mostaza',
      'ketchup': 'ketchup',
      'mayonesa': 'mayonesa',
      'hummus': 'hummus',
      'pesto': 'pesto',
      'salsa tomate': 'salsa tomate',
      'salsa picante': 'salsa picante',
      'salsa bbq': 'salsa bbq',

      // ===== ESPECIAS/HIERBAS =====
      'canela': 'canela',
      'pimienta': 'pimienta',
      'paprika': 'paprika',
      'pimenton': 'pimenton',
      'comino': 'comino',
      'curry': 'curry',
      'curry polvo': 'curry polvo',
      'cúrcuma': 'curcuma',
      'jengibre': 'jengibre',
      'cilantro': 'cilantro',
      'perejil': 'perejil',
      'albahaca': 'albahaca',
      'orégano': 'oregano',
      'tomillo': 'tomillo',
      'romero': 'romero',
      'laurel': 'laurel',
      'anís': 'anis',
      'clavo': 'clavo',
      'nuez moscada': 'nuez moscada',
      'sal': 'sal',

      // ===== PROTEÍNAS EN POLVO =====
      'proteina suero': 'proteina suero',
      'proteina de suero': 'proteina suero',
      'whey protein': 'proteina suero',
      'proteina caseina': 'proteina caseina',
      'proteina vegana': 'proteina vegana',
      'proteina guisante': 'proteina guisante',
      'proteina cáñamo': 'proteina cáñamo',

      // ===== OTROS =====
      'miel': 'miel',
      'miel de abeja': 'miel',
      'melaza': 'melaza',
      'sirope maple': 'sirope maple',
      'azúcar': 'azucar',
      'stevia': 'stevia',
      'chocolate negro': 'chocolate negro',
      'cacao en polvo': 'cacao en polvo',
      'levadura nutricional': 'levadura nutricional',
      'pan': 'pan',
      'pan integral': 'pan integral',
      'tortilla maiz': 'tortilla maiz',
      'tortilla trigo': 'tortilla trigo',
      'tortita arroz': 'tortita arroz',
      'granola': 'granola',
      'muesli': 'muesli',
      'cereal': 'cereal',
      'caldo pollo': 'caldo pollo',
      'caldo vegetales': 'caldo vegetales',
      'caldo res': 'caldo res',

            // ===== HUEVOS =====
      'huevos': 'huevo',
      'huevo': 'huevo',

      // ===== ACEITES (TODO A ACEITE OLIVA) =====
      'aceite de oliva virgen extra': 'aceite oliva',
      'aceite de oliva virgen extra (para tortilla)': 'aceite oliva',
      'aceite de oliva virgen extra (para ensalada)': 'aceite oliva',
      'aceite sesamo': 'aceite sesamo',
      'aceite de sesamo': 'aceite sesamo',
      'aceite de coco': 'aceite coco',

      // ===== QUESOS =====
      'queso': 'queso',
      'queso parmesano': 'queso parmesano',
      'queso parmesano rallado': 'queso parmesano',
      'queso mozzarella': 'queso mozzarella',

      // ===== PASTAS =====
      'noodles arroz': 'noodles arroz',
      'noodles de arroz': 'noodles arroz',

      // ===== LENTEJAS =====
      'lentejas pardinas': 'lentejas',

      // ===== GARBANZOS =====
      'garbanzos cocidos': 'garbanzos',

      // ===== FRUTOS ROJOS =====
      'frutos rojos': 'frutos rojos',
      'frutos rojos variados': 'frutos rojos',
      'arandanos': 'arandano',
      'frambuesas': 'frambuesa',
      'moras': 'mora',
      'fresas': 'fresa',

      // ===== VINAGRES =====
      'vinagre': 'vinagre',
      'vinagre de manzana': 'vinagre',

      // ===== PROTEÍNAS EN POLVO =====
      'proteina en polvo': 'proteina suero',
      'proteina en polvo (sabor neutro o vainilla)': 'proteina suero',

      // ===== LECHES VEGETALES =====
      'leche de almendras sin azucar': 'leche almendras',
      'leche de coco light': 'leche coco',

      // ===== MANTEQUILLAS =====
      'mantequilla de cacahuete natural': 'mantequilla cacahuete',
      'crema cacahuete': 'mantequilla cacahuete',

      // ===== SEMILLAS =====
      'semillas de chia': 'semillas chia',
      'chia': 'semillas chia',
      'pipa calabaza': 'semillas calabaza',

      // ===== POLLO =====
      'pechuga de pollo': 'pollo',
      'pechuga de pollo cocida': 'pollo',

      // ===== PAVO =====
      'pavo picado': 'pavo',

      // ===== PESCADOS =====
      'filete merluza': 'merluza',
      'gambas peladas': 'gambas',

      // ===== ESPECIAS =====
      'perejil fresco': 'perejil',
      'oregano': 'oregano',

      // ===== OTROS =====
      'pan hamburguesa integral': 'pan',
      'tortilla de trigo': 'tortilla',
      'tortilla de trigo (equivalente a 1.5 tortillas grandes)': 'tortilla',
      'tortilla de trigo grande': 'tortilla',
      'tostada arroz': 'tostada arroz',
      'copos avena': 'avena',
      'quinoa (seca)': 'quinoa',
      'tofu firme': 'tofu',
      'sirope arce': 'sirope arce',
      'salsa tahini': 'salsa tahini',
      'pasta curry': 'pasta curry',
      'pasta de curry': 'pasta curry',
      'pesto albahaca': 'pesto',
      'aderezo ligero': 'aderezo',
      'salsa de tomate': 'salsa tomate',
      'salsa de tomate natural': 'salsa tomate',
      'tomate triturado': 'tomate',
      'falafel': 'falafel',
      'chorizo ligero': 'chorizo',
      'bacon crujiente': 'bacon',
      'bacon crujiente (bajo en grasa)': 'bacon',
      'frijol negro': 'frijol negro',
      'frijoles negros cocidos': 'frijol negro',
      'masa pizza integral': 'masa pizza',
    };

    if (map.containsKey(s)) {
      s = map[s]!;
    }

    return s.isEmpty ? raw.toLowerCase().trim() : s;
  }

  String _stripAccents(String input) {
    const withAccent = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const without =   'aaaaaeeeeiiiiooooouuuunc';
    final out = StringBuffer();
    for (final ch in input.characters) {
      final idx = withAccent.indexOf(ch);
      out.write(idx >= 0 ? without[idx] : ch);
    }
    return out.toString();
  }
}

//TODO: AHORA MISMO SE USA EL SMART, SI FUNCIONA BIEN ESTE SE PUEDE BORRAR