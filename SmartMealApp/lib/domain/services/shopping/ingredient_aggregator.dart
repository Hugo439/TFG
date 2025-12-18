import 'ingredient_parser.dart' as parser;
import 'package:smartmeal/domain/usecases/shopping/get_ingredient_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_prices_by_category_usecase.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart' as price_unit;
import 'package:smartmeal/domain/value_objects/shopping_item_unit_kind.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';

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

  String _normalizeName(String name) {
    return name.trim().toLowerCase();
  }
}

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

  double? _matchPrice(Map<String, PriceRange> prices, String n) {
    for (final entry in prices.entries) {
      final key = entry.key;
      if (n.contains(key) || key.contains(n)) {
        return entry.value.avg;
      }
    }
    return null;
  }

  // Precarga todos los precios de una categoría a la vez
  Future<void> preloadCategoryPrices(String category) async {
    await _loadCategory(category);
  }

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

  price_unit.UnitKind _mapUnitKind(UnitKind kind) {
    switch (kind) {
      case UnitKind.weight:
        return price_unit.UnitKind.weight;
      case UnitKind.volume:
        return price_unit.UnitKind.volume;
      case UnitKind.unit:
        return price_unit.UnitKind.unit;
    }
  }
}

class _IngredientAgg {
  final String name;
  final List<String> usedInMenus;
  double totalBase;
  UnitKind? unitKind;

  _IngredientAgg({required this.name})
    : usedInMenus = [],
      totalBase = 0,
      unitKind = null;

  void addQuantity(double value, UnitKind kind) {
    unitKind ??= kind;
    if (unitKind == kind) {
      totalBase += value;
    }
  }

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
