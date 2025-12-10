import 'ingredient_parser.dart';

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

  void addPortion(IngredientPortion portion, String menuName) {
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
  double estimatePrice(UnitKind kind, double base) {
    if (kind == UnitKind.weight) {
      final kg = base / 1000.0;
      return (kg * 8.0).clamp(0.5, 20.0);
    }
    if (kind == UnitKind.volume) {
      final liters = base / 1000.0;
      return (liters * 3.0).clamp(0.3, 15.0);
    }
    return (base * 1.0).clamp(0.2, 10.0);
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