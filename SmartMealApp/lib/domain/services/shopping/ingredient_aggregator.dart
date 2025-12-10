import 'ingredient_parser.dart' as parser;
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_unit_kind.dart';

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
  final PriceRepository priceRepository;

  PriceEstimator({required this.priceRepository});

  Future<double> estimatePrice({
    required String ingredientName,
    required String category,
    required UnitKind kind,
    required double base,
  }) async {
    return await priceRepository.estimatePrice(
      ingredientName: ingredientName,
      category: category,
      quantityBase: base,
      unitKind: kind == UnitKind.weight
          ? 'weight'
          : kind == UnitKind.volume
              ? 'volume'
              : 'unit',
    );
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

  String _format(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}