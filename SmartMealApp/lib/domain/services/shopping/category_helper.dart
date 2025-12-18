import 'package:smartmeal/domain/value_objects/shopping_item_category.dart';

class CategoryHelper {
  ShoppingItemCategory guessCategory(String ingredientName) {
    final n = ingredientName.toLowerCase();

    // ===== LÁCTEOS =====
    if (n.contains('queso') ||
        n.contains('feta') ||
        n.contains('yogur') ||
        n.contains('leche') ||
        n.contains('mantequilla') ||
        n.contains('nata') ||
        n.contains('requeson') ||
        n.contains('cottage') ||
        n.contains('mozzarella') ||
        n.contains('parmesano')) {
      return ShoppingItemCategory.lacteos;
    }

    // ===== CARNES Y PESCADOS =====
    if (n.contains('pollo') ||
        n.contains('pavo') ||
        n.contains('carne') ||
        n.contains('cerdo') ||
        n.contains('ternera') ||
        n.contains('salmon') ||
        n.contains('atun') ||
        n.contains('merluza') ||
        n.contains('bacalao') ||
        n.contains('gambas') ||
        n.contains('langostinos') ||
        n.contains('res') ||
        n.contains('huevo') ||
        n.contains('chorizo') ||
        n.contains('bacon')) {
      return ShoppingItemCategory.carnesYPescados;
    }

    // ===== FRUTAS Y VERDURAS =====
    if (n.contains('manzana') ||
        n.contains('platano') ||
        n.contains('naranja') ||
        n.contains('kiwi') ||
        n.contains('pera') ||
        n.contains('fresa') ||
        n.contains('frambuesa') ||
        n.contains('arandano') ||
        n.contains('mango') ||
        n.contains('melocoton') ||
        n.contains('uva') ||
        n.contains('sandia') ||
        n.contains('melon') ||
        n.contains('aguacate') ||
        n.contains('limon') ||
        n.contains('lima') ||
        n.contains('tomate') ||
        n.contains('cebolla') ||
        n.contains('lechuga') ||
        n.contains('espinaca') ||
        n.contains('brocoli') ||
        n.contains('coliflor') ||
        n.contains('zanahoria') ||
        n.contains('pepino') ||
        n.contains('pimiento') ||
        n.contains('calabacin') ||
        n.contains('berenjena') ||
        n.contains('patata') ||
        n.contains('boniato') ||
        n.contains('batata') ||
        n.contains('champiñon') ||
        n.contains('champinon') ||
        n.contains('seta') ||
        n.contains('apio') ||
        n.contains('calabaza') ||
        n.contains('espárrago') ||
        n.contains('esparrag') ||
        n.contains('frutos rojos') ||
        n.contains('frutos secos') ||
        n.contains('judia verde') ||
        n.contains('judias') ||
        n.contains('alcachofa')) {
      return ShoppingItemCategory.frutasYVerduras;
    }

    // ===== PANADERÍA =====
    if (n.contains('pan') ||
        n.contains('baguette') ||
        n.contains('hogaza') ||
        n.contains('tortilla') ||
        n.contains('tostada') ||
        n.contains('granola') ||
        n.contains('muesli') ||
        n.contains('masa pizza')) {
      return ShoppingItemCategory.panaderia;
    }

    // ===== BEBIDAS =====
    if (n.contains('agua') ||
        n.contains('zumo') ||
        n.contains('cafe') ||
        n.contains('te') ||
        n.contains('infusion') ||
        n.contains('refresco') ||
        n.contains('batido') ||
        n.contains('caldo')) {
      return ShoppingItemCategory.bebidas;
    }

    // ===== SNACKS =====
    if (n.contains('almendra') && !n.contains('leche') ||
        n.contains('nuez') && !n.contains('nuez moscada') ||
        n.contains('anacardo') ||
        n.contains('pistacho') ||
        n.contains('cacahuete') ||
        n.contains('pasa') ||
        n.contains('datil') ||
        n.contains('chocolate') ||
        n.contains('galleta') ||
        n.contains('barrita') ||
        n.contains('granola')) {
      return ShoppingItemCategory.snacks;
    }

    // ===== OTROS (cereales, legumbres, aceites, especias, proteínas, etc.) =====
    // Arroz
    if (n.contains('arroz') ||
        n.contains('quinoa') ||
        n.contains('cuscus') ||
        n.contains('pasta') ||
        n.contains('noodle')) {
      return ShoppingItemCategory.otros;
    }

    // Legumbres
    if (n.contains('lenteja') ||
        n.contains('garbanzo') ||
        n.contains('frijol') ||
        n.contains('judia')) {
      return ShoppingItemCategory.otros;
    }

    // Aceites y vinagres
    if (n.contains('aceite') ||
        n.contains('vinagre') ||
        n.contains('salsa soja') ||
        n.contains('mostaza')) {
      return ShoppingItemCategory.otros;
    }

    // Proteínas en polvo
    if (n.contains('proteina') || n.contains('whey') || n.contains('suero')) {
      return ShoppingItemCategory.otros;
    }

    // Especias y condimentos
    if (n.contains('sal') ||
        n.contains('pimienta') ||
        n.contains('comino') ||
        n.contains('cilantro') ||
        n.contains('perejil') ||
        n.contains('oregano') ||
        n.contains('canela') ||
        n.contains('laurel') ||
        n.contains('jengibre') ||
        n.contains('curcuma') ||
        n.contains('curry')) {
      return ShoppingItemCategory.otros;
    }

    // Otros productos
    if (n.contains('hummus') ||
        n.contains('tofu') ||
        n.contains('edamame') ||
        n.contains('miel') ||
        n.contains('sirope') ||
        n.contains('pesto') ||
        n.contains('tahini') ||
        n.contains('falafel') ||
        n.contains('semilla') ||
        n.contains('chia') ||
        n.contains('avena')) {
      return ShoppingItemCategory.otros;
    }

    // Default
    return ShoppingItemCategory.otros;
  }
}

//TODO: AHORA MISMO SE USA EL SMART, SI FUNCIONA BIEN ESTE SE PUEDE BORRAR
