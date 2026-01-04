import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';

final SmartCategoryHelper _categoryHelper = SmartCategoryHelper();
final List<Map<String, dynamic>> productos = [
  {"nombre": "aceite coco", "precio": 6.5, "unidad": "litro"},
  {"nombre": "aceite oliva", "precio": 9.0, "unidad": "litro"},
  {"nombre": "mayonesa ligera", "precio": 2.2, "unidad": "unidad"},
  {"nombre": "mostaza", "precio": 1.3, "unidad": "unidad"},
  {"nombre": "salsa soja", "precio": 2.0, "unidad": "unidad"},
  {"nombre": "sirope arce", "precio": 8.0, "unidad": "litro"},
  {"nombre": "tahini", "precio": 6.5, "unidad": "kilo"},
  {"nombre": "mantequilla cacahuete", "precio": 4.5, "unidad": "kilo"},
  {"nombre": "crema cacahuete", "precio": 4.5, "unidad": "kilo"},
  {"nombre": "hummus", "precio": 6.0, "unidad": "kilo"},
  {"nombre": "aguacate", "precio": 2.5, "unidad": "kilo"},
  {"nombre": "arandano", "precio": 8.0, "unidad": "kilo"},
  {"nombre": "datiles", "precio": 4.0, "unidad": "kilo"},
  {"nombre": "lima", "precio": 3.0, "unidad": "kilo"},
  {"nombre": "limon", "precio": 1.8, "unidad": "kilo"},
  {"nombre": "manzana", "precio": 2.0, "unidad": "kilo"},
  {"nombre": "pera", "precio": 2.2, "unidad": "kilo"},
  {"nombre": "piña", "precio": 2.5, "unidad": "unidad"},
  {"nombre": "platano", "precio": 1.7, "unidad": "kilo"},
  {"nombre": "mezcla fruta", "precio": 3.0, "unidad": "kilo"},
  {"nombre": "mermelada azucar", "precio": 2.5, "unidad": "unidad"},
  {"nombre": "ajo", "precio": 3.0, "unidad": "kilo"},
  {"nombre": "diente ajo", "precio": 0.1, "unidad": "unidad"},
  {"nombre": "cebolla", "precio": 1.5, "unidad": "kilo"},
  {"nombre": "cebolla morada", "precio": 2.0, "unidad": "kilo"},
  {"nombre": "brocoli", "precio": 2.3, "unidad": "kilo"},
  {"nombre": "calabacin", "precio": 1.8, "unidad": "kilo"},
  {"nombre": "calabaza", "precio": 1.5, "unidad": "kilo"},
  {"nombre": "batata", "precio": 2.2, "unidad": "kilo"},
  {"nombre": "col", "precio": 1.3, "unidad": "kilo"},
  {"nombre": "espinaca", "precio": 4.0, "unidad": "kilo"},
  {"nombre": "lechuga", "precio": 1.2, "unidad": "unidad"},
  {"nombre": "pepino", "precio": 1.5, "unidad": "kilo"},
  {"nombre": "pimiento", "precio": 2.8, "unidad": "kilo"},
  {"nombre": "tomate", "precio": 2.5, "unidad": "kilo"},
  {"nombre": "tomate triturado", "precio": 1.2, "unidad": "unidad"},
  {"nombre": "esparrago", "precio": 3.5, "unidad": "kilo"},
  {"nombre": "setas", "precio": 4.0, "unidad": "kilo"},
  {"nombre": "alubia negros", "precio": 3.0, "unidad": "kilo"},
  {"nombre": "alubia negros cocidos", "precio": 1.4, "unidad": "unidad"},
  {"nombre": "alubia verde", "precio": 2.5, "unidad": "kilo"},
  {"nombre": "garbanzo", "precio": 2.2, "unidad": "kilo"},
  {"nombre": "garbanzo cocido", "precio": 1.3, "unidad": "unidad"},
  {"nombre": "garbanzo cocidos", "precio": 1.3, "unidad": "unidad"},
  {"nombre": "lenteja", "precio": 2.0, "unidad": "kilo"},
  {"nombre": "lenteja cocida", "precio": 1.3, "unidad": "unidad"},
  {"nombre": "lenteja cocidas", "precio": 1.3, "unidad": "unidad"},
  {"nombre": "lenteja rojas", "precio": 2.5, "unidad": "kilo"},
  {"nombre": "frijol negro", "precio": 2.8, "unidad": "kilo"},
  {"nombre": "guisante", "precio": 2.0, "unidad": "kilo"},
  {"nombre": "guisantes", "precio": 2.0, "unidad": "kilo"},
  {"nombre": "edamame", "precio": 3.5, "unidad": "kilo"},
  {"nombre": "tofu", "precio": 6.0, "unidad": "kilo"},
  {"nombre": "arroz", "precio": 1.5, "unidad": "kilo"},
  {"nombre": "arroz basmati", "precio": 2.8, "unidad": "kilo"},
  {"nombre": "arroz integral", "precio": 2.0, "unidad": "kilo"},
  {"nombre": "pasta integral", "precio": 1.8, "unidad": "kilo"},
  {"nombre": "pasta curry", "precio": 2.5, "unidad": "kilo"},
  {"nombre": "quinoa", "precio": 4.5, "unidad": "kilo"},
  {"nombre": "avena", "precio": 1.4, "unidad": "kilo"},
  {"nombre": "granola", "precio": 4.5, "unidad": "kilo"},
  {"nombre": "muesli", "precio": 3.5, "unidad": "kilo"},
  {"nombre": "tostada arroz", "precio": 5.0, "unidad": "kilo"},
  {"nombre": "tortilla maiz", "precio": 2.0, "unidad": "unidad"},
  {"nombre": "tortilla trigo", "precio": 2.2, "unidad": "unidad"},
  {"nombre": "masa pizza integral", "precio": 2.5, "unidad": "unidad"},
  {"nombre": "pan integral", "precio": 2.2, "unidad": "unidad"},
  {"nombre": "pan hamburguesa integral", "precio": 2.5, "unidad": "unidad"},
  {"nombre": "bagel", "precio": 1.0, "unidad": "unidad"},
  {"nombre": "bagel integral", "precio": 1.2, "unidad": "unidad"},
  {"nombre": "almendra", "precio": 10.0, "unidad": "kilo"},
  {"nombre": "almendras", "precio": 10.0, "unidad": "kilo"},
  {"nombre": "nuez", "precio": 9.0, "unidad": "kilo"},
  {"nombre": "nueces", "precio": 9.0, "unidad": "kilo"},
  {"nombre": "frutos secos", "precio": 8.0, "unidad": "kilo"},
  {"nombre": "frutos secos mix", "precio": 9.0, "unidad": "kilo"},
  {"nombre": "semillas chia", "precio": 7.0, "unidad": "kilo"},
  {"nombre": "chia", "precio": 7.0, "unidad": "kilo"},
  {"nombre": "semillas lino", "precio": 4.0, "unidad": "kilo"},
  {"nombre": "sesamo", "precio": 5.0, "unidad": "kilo"},
  {"nombre": "pipa calabaza", "precio": 6.0, "unidad": "kilo"},
  {"nombre": "carne res", "precio": 11.0, "unidad": "kilo"},
  {"nombre": "carne picada ternera", "precio": 9.5, "unidad": "kilo"},
  {"nombre": "ternera guisar", "precio": 10.0, "unidad": "kilo"},
  {"nombre": "ternera magra", "precio": 12.0, "unidad": "kilo"},
  {"nombre": "ternera picada magra", "precio": 11.5, "unidad": "kilo"},
  {"nombre": "pollo pechuga", "precio": 7.5, "unidad": "kilo"},
  {"nombre": "pavo pechuga", "precio": 9.0, "unidad": "kilo"},
  {"nombre": "pescado blanco", "precio": 8.0, "unidad": "kilo"},
  {"nombre": "merluza", "precio": 9.5, "unidad": "kilo"},
  {"nombre": "salmon", "precio": 13.0, "unidad": "kilo"},
  {"nombre": "atun", "precio": 12.0, "unidad": "kilo"},
  {"nombre": "bacalao", "precio": 9.0, "unidad": "kilo"},
  {"nombre": "mejillones", "precio": 4.5, "unidad": "kilo"},
  {"nombre": "huevo", "precio": 0.3, "unidad": "unidad"},
  {"nombre": "claras huevo", "precio": 3.0, "unidad": "litro"},
  {"nombre": "huevo huevo", "precio": 0.3, "unidad": "unidad"},
  {"nombre": "leche", "precio": 1.0, "unidad": "litro"},
  {"nombre": "leche almendras", "precio": 1.8, "unidad": "litro"},
  {"nombre": "leche coco", "precio": 2.2, "unidad": "litro"},
  {"nombre": "kefir", "precio": 1.8, "unidad": "litro"},
  {"nombre": "yogur griego", "precio": 2.5, "unidad": "kilo"},
  {"nombre": "queso", "precio": 9.0, "unidad": "kilo"},
  {"nombre": "queso feta", "precio": 10.0, "unidad": "kilo"},
  {"nombre": "queso mozzarella", "precio": 8.0, "unidad": "kilo"},
  {"nombre": "requeson", "precio": 6.5, "unidad": "kilo"},
  {"nombre": "proteina suero", "precio": 20.0, "unidad": "kilo"},
  {"nombre": "canela", "precio": 15.0, "unidad": "kilo"},
  {"nombre": "canela molida", "precio": 16.0, "unidad": "kilo"},
  {"nombre": "curry en polvo", "precio": 14.0, "unidad": "kilo"},
  {"nombre": "comino", "precio": 12.0, "unidad": "kilo"},
  {"nombre": "laurel", "precio": 10.0, "unidad": "kilo"},
  {"nombre": "oregano", "precio": 12.0, "unidad": "kilo"},
  {"nombre": "oregano seco", "precio": 13.0, "unidad": "kilo"},
  {"nombre": "nuez moscada", "precio": 18.0, "unidad": "kilo"},
  {"nombre": "pimienta", "precio": 18.0, "unidad": "kilo"},
  {"nombre": "sal", "precio": 0.5, "unidad": "kilo"},
  {"nombre": "romero", "precio": 10.0, "unidad": "kilo"},
  {"nombre": "eneldo", "precio": 11.0, "unidad": "kilo"},
  {"nombre": "perejil", "precio": 8.0, "unidad": "kilo"},
  {"nombre": "jengibre", "precio": 3.0, "unidad": "kilo"},
  {"nombre": "cilantro", "precio": 9.0, "unidad": "kilo"},
  {"nombre": "especias taco", "precio": 18.0, "unidad": "kilo"},
  {"nombre": "aceituna", "precio": 3.5, "unidad": "kilo"},
  {"nombre": "aceitunas", "precio": 3.5, "unidad": "kilo"},
  {"nombre": "aceitunas negras", "precio": 4.0, "unidad": "kilo"},
  {"nombre": "alcaparra", "precio": 12.0, "unidad": "kilo"},
  {"nombre": "alcaparras", "precio": 12.0, "unidad": "kilo"},
  {"nombre": "maiz", "precio": 1.5, "unidad": "kilo"},
  {"nombre": "miel", "precio": 6.0, "unidad": "kilo"},
];

Future<void> subirCatalogoPreciosRespetandoCampos() async {
  final firestore = FirebaseFirestore.instance;

  for (final producto in productos) {
    final docRef = firestore
        .collection('price_catalog')
        .doc(producto['nombre'].replaceAll(' ', '_'));
    final docSnap = await docRef.get();
    final categoria = _categoryHelper
        .guessCategory(producto['nombre'])
        .firestoreKey;

    if (docSnap.exists) {
      // Si existe, solo añade los campos que no estén presentes
      final data = docSnap.data()!;
      final Map<String, dynamic> updateData = {};

      if (!data.containsKey('priceRef')) {
        updateData['priceRef'] = producto['precio'];
      }
      if (!data.containsKey('unitKind')) {
        updateData['unitKind'] = _mapUnidad(producto['unidad']);
      }
      if (!data.containsKey('displayName')) {
        updateData['displayName'] = producto['nombre'];
      }
      if (!data.containsKey('normalizedName')) {
        updateData['normalizedName'] = producto['nombre'].toLowerCase();
      }
      if (!data.containsKey('category')) updateData['category'] = categoria;

      if (updateData.isNotEmpty) {
        await docRef.update(updateData);
        print('Actualizado: ${producto['nombre']}');
      } else {
        print('Sin cambios: ${producto['nombre']}');
      }
    } else {
      // Si no existe, crea el documento con los campos estándar
      await docRef.set({
        'displayName': producto['nombre'],
        'normalizedName': producto['nombre'].toLowerCase(),
        'priceRef': producto['precio'],
        'unitKind': _mapUnidad(producto['unidad']),
        'brand': 'Genérico',
        'category': categoria,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Creado: ${producto['nombre']}');
    }
  }
  print('Catálogo de precios actualizado.');
}

String _mapUnidad(String unidad) {
  switch (unidad) {
    case 'kilo':
      return 'weight';
    case 'litro':
      return 'volume';
    case 'unidad':
      return 'unit';
    default:
      return 'unit';
  }
}

//TODO: archivo para actualizar el catálogo de precios
