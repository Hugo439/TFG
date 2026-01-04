import 'ingredient_parser.dart' as parser;
import 'package:smartmeal/domain/usecases/shopping/get_ingredient_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_prices_by_category_usecase.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';

/// Representa un ingrediente agregado desde múltiples recetas.
///
/// Propiedades:
/// - **name**: nombre normalizado del ingrediente
/// - **unitKind**: tipo de unidad (weight, volume, unit)
/// - **totalBase**: cantidad total en unidad base (g, ml, o unidades)
/// - **usedInMenus**: lista de IDs de menús donde aparece
/// - **quantityLabel**: label legible (ej: "500 g", "1.5 L", "3 uds")
class AggregatedIngredient {
  final String name;
  final UnitKind unitKind;
  final double totalBase;
  final List<String> usedInMenus;
  final String quantityLabel;

  AggregatedIngredient({
    required this.name,
    required this.unitKind,
    required this.totalBase,
    required this.usedInMenus,
    required this.quantityLabel,
  });
}

class IngredientAggregator {
  final Map<String, _IngredientAgg> _acc = {};

  /// Añade una porción de ingrediente al agregado.
  ///
  /// [portion] - Resultado del parsing (nombre, cantidad, unitKind).
  /// [menuName] - ID del menú de donde viene este ingrediente.
  ///
  /// Lógica:
  /// 1. Normaliza nombre a lowercase y trim
  /// 2. Agrupa por nombre normalizado
  /// 3. Suma cantidad si mismo unitKind
  /// 4. Añade menuName a lista de menús (si no está ya)
  void addPortion(parser.IngredientPortion portion, String menuName) {
    if (portion.name.trim().isEmpty) return;

    // Normalizar el nombre ANTES de agregar
    final normalizedName = _normalizeName(portion.name);
    final key = normalizedName;

    _acc.putIfAbsent(key, () => _IngredientAgg(name: normalizedName));

    final group = _acc[key]!;
    if (!group.usedInMenus.contains(menuName)) {
      group.usedInMenus.add(menuName);
    }
    group.addQuantity(portion.quantityBase, portion.unitKind);
  }

  /// Convierte agregados a lista de AggregatedIngredient.
  ///
  /// Returns: Lista con todos los ingredientes agregados.
  ///
  /// Genera quantityLabel legible:
  /// - weight: "500 g" o "1.5 kg"
  /// - volume: "750 ml" o "2 L"
  /// - unit: "3 uds"
  List<AggregatedIngredient> toList() {
    return _acc.values.map((g) {
      final kind = g.unitKind ?? UnitKind.unit;
      final qtyLabel = g.renderQuantity();
      return AggregatedIngredient(
        name: g.name,
        unitKind: kind,
        totalBase: g.totalBase,
        usedInMenus: List<String>.from(g.usedInMenus),
        quantityLabel: qtyLabel,
      );
    }).toList();
  }

  /// Normaliza nombre: trim + lowercase.
  ///
  /// Nota: Normalización básica. SmartIngredientNormalizer hace
  /// normalización avanzada con sinónimos y plurales.
  String _normalizeName(String name) {
    return name.trim().toLowerCase();
  }
}

/// Servicio para estimar precios de ingredientes con caché por categoría.
///
/// Responsabilidades:
/// - Estimar precio de ingrediente según cantidad y unidad
/// - Cachear precios por categoría para reducir llamadas a base de datos
/// - Hacer matching fuzzy entre nombre de ingrediente y precios disponibles
/// - Convertir unidades base (g, ml, ud) a precio final
///
/// Estrategia de caché:
/// 1. Si categoría está en _categoryCache, buscar match local
/// 2. Si no, cargar toda la categoría una vez y cachear
/// 3. Fallback a UseCase puntual si no encuentra match
///
/// Cálculos:
/// - **Weight**: precio/kg × (base/1000)
/// - **Volume**: precio/L × (base/1000)
/// - **Unit**: precio/ud × base
/// - Clamps: weight [0.1, 100.0], volume [0.1, 50.0], unit [0.1, 50.0]
class PriceEstimator {
  final GetIngredientPriceUseCase getIngredientPriceUseCase;
  final GetPricesByCategoryUseCase getPricesByCategoryUseCase;
  final String? userId;

  // Caché local: categoría -> mapa de precios de la categoría
  final Map<String, Map<String, PriceRange>> _categoryCache = {};

  PriceEstimator({
    required this.getIngredientPriceUseCase,
    required this.getPricesByCategoryUseCase,
    this.userId,
  });

  /// Estima precio de un ingrediente.
  ///
  /// [ingredientName] - Nombre del ingrediente.
  /// [category] - Categoría (lacteos, carnesYPescados, etc.).
  /// [kind] - Tipo de unidad (weight, volume, unit).
  /// [base] - Cantidad en unidad base (g, ml, o unidades).
  ///
  /// Returns: Precio estimado en euros.
  ///
  /// Algoritmo:
  /// 1. Buscar en caché de categoría
  /// 2. Si no en caché, cargar categoría completa y cachear
  /// 3. Hacer matching fuzzy (contains) entre nombre e ingredientes de la categoría
  /// 4. Calcular precio según unitKind
  /// 5. Fallback a UseCase puntual si no encuentra
  Future<double> estimatePrice({
    required String ingredientName,
    required String category,
    required UnitKind kind,
    required double base,
  }) async {
    final n = ingredientName.toLowerCase();

    // 1) Si tenemos la categoría en caché, hacer búsqueda rápida sin llamadas async
    if (_categoryCache.containsKey(category)) {
      final prices = _categoryCache[category]!;
      final matched = _matchPrice(prices, n);
      if (matched != null) {
        return _calculatePrice(matched, base, kind);
      }
    }

    // 2) Si no está en caché, cargar toda la categoría una vez
    final prices = await _loadCategory(category);
    final matched = _matchPrice(prices, n);
    if (matched != null) {
      return _calculatePrice(matched, base, kind);
    }

    // 3) Fallback a llamada puntual (debería ser raro)
    final result = await getIngredientPriceUseCase(
      GetIngredientPriceParams(
        ingredientName: ingredientName,
        category: category,
        quantityBase: base,
        unitKind: _mapUnitKind(kind),
        userId: userId,
      ),
    );

    return result.fold((_) => 0.0, (r) => r.price);
  }

  /// Carga precios de una categoría completa y cachea.
  ///
  /// [category] - Categoría a cargar.
  ///
  /// Returns: Map ingredientName (lowercase) → PriceRange.
  Future<Map<String, PriceRange>> _loadCategory(String category) async {
    if (_categoryCache.containsKey(category)) {
      return _categoryCache[category]!;
    }
    final prices = await getPricesByCategoryUseCase(
      GetPricesByCategoryParams(category: category),
    );
    // Normalizar claves a lower-case
    final normalized = {
      for (final entry in prices.entries) entry.key.toLowerCase(): entry.value,
    };
    _categoryCache[category] = normalized;
    return normalized;
  }

  /// Busca precio que coincida con nombre de ingrediente.
  ///
  /// [prices] - Mapa de precios de la categoría.
  /// [n] - Nombre del ingrediente (lowercase).
  ///
  /// Returns: Precio promedio si encuentra match, null si no.
  ///
  /// Matching: usa contains bidireccional (n contiene key o key contiene n).
  double? _matchPrice(Map<String, PriceRange> prices, String n) {
    for (final entry in prices.entries) {
      final key = entry.key;
      if (n.contains(key) || key.contains(n)) {
        return entry.value.avg;
      }
    }
    return null;
  }

  /// Precarga precios de una categoría completa en caché.
  ///
  /// Útil para optimización: cargar todas las categorías antes de procesar
  /// listas de compra grandes.
  ///
  /// [category] - Categoría a precargar.
  Future<void> preloadCategoryPrices(String category) async {
    await _loadCategory(category);
  }

  /// Calcula precio final según unitKind y cantidad base.
  ///
  /// [pricePerUnit] - Precio por unidad (kg, L, o ud).
  /// [base] - Cantidad en unidad base (g, ml, o ud).
  /// [kind] - Tipo de unidad.
  ///
  /// Returns: Precio calculado con clamps:
  /// - weight: [0.1, 100.0]
  /// - volume: [0.1, 50.0]
  /// - unit: [0.1, 50.0]
  ///
  /// Fórmulas:
  /// - weight: precio/kg × (g / 1000)
  /// - volume: precio/L × (ml / 1000)
  /// - unit: precio/ud × cantidad
  double _calculatePrice(double pricePerUnit, double base, UnitKind kind) {
    final unitStr = kind == UnitKind.weight
        ? 'weight'
        : kind == UnitKind.volume
        ? 'volume'
        : 'unit';

    if (unitStr == 'weight') {
      final kg = base / 1000.0;
      return (pricePerUnit * kg).clamp(0.1, 100.0);
    }
    if (unitStr == 'volume') {
      final liters = base / 1000.0;
      return (pricePerUnit * liters).clamp(0.1, 50.0);
    }
    return (pricePerUnit * base).clamp(0.1, 50.0);
  }

  UnitKind _mapUnitKind(UnitKind kind) {
    switch (kind) {
      case UnitKind.weight:
        return UnitKind.weight;
      case UnitKind.volume:
        return UnitKind.volume;
      case UnitKind.unit:
        return UnitKind.unit;
    }
  }
}

/// Clase helper interna para acumular cantidades de un ingrediente.
///
/// Propiedades:
/// - **name**: nombre normalizado
/// - **usedInMenus**: lista de IDs de menús
/// - **totalBase**: suma de cantidades en unidad base
/// - **unitKind**: tipo de unidad (se fija con la primera adición)
///
/// Restricción: solo suma si las cantidades tienen mismo unitKind.
class _IngredientAgg {
  final String name;
  final List<String> usedInMenus;
  double totalBase;
  UnitKind? unitKind;

  _IngredientAgg({required this.name})
    : usedInMenus = [],
      totalBase = 0,
      unitKind = null;

  /// Añade cantidad al total si unitKind coincide.
  ///
  /// [value] - Cantidad a añadir.
  /// [kind] - Tipo de unidad.
  ///
  /// Lógica:
  /// - Primera vez: fija unitKind y suma
  /// - Siguientes: solo suma si kind == unitKind
  void addQuantity(double value, UnitKind kind) {
    unitKind ??= kind;
    if (unitKind == kind) {
      totalBase += value;
    }
  }

  /// Renderiza cantidad como string legible.
  ///
  /// Returns:
  /// - weight: "500 g" o "1.5 kg" (si >= 1000g)
  /// - volume: "750 ml" o "2 L" (si >= 1000ml)
  /// - unit: "3 uds"
  ///
  /// Formato: sin decimales si es entero, 2 decimales si tiene fracción.
  String renderQuantity() {
    final kind = unitKind ?? UnitKind.unit;
    if (kind == UnitKind.weight) {
      if (totalBase >= 1000) return '${_format(totalBase / 1000.0)} kg';
      return '${_format(totalBase)} g';
    }
    if (kind == UnitKind.volume) {
      if (totalBase >= 1000) return '${_format(totalBase / 1000.0)} L';
      return '${_format(totalBase)} ml';
    }
    return '${_format(totalBase)} uds';
  }

  String _format(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
