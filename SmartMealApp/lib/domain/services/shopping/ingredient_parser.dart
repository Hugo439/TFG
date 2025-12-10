enum UnitKind { weight, volume, unit }

class IngredientPortion {
  final String name;
  final double quantityBase; // g, ml, uds según unitKind
  final UnitKind unitKind;

  IngredientPortion({
    required this.name,
    required this.quantityBase,
    required this.unitKind,
  });

  IngredientPortion copyWith({String? name, double? quantityBase, UnitKind? unitKind}) {
    return IngredientPortion(
      name: name ?? this.name,
      quantityBase: quantityBase ?? this.quantityBase,
      unitKind: unitKind ?? this.unitKind,
    );
  }
}

class IngredientParser {
  IngredientPortion parse(String raw) {
    final regex = RegExp(r'^\s*([\d.,]+)\s*([a-zA-Záéíóúüñ%]+)?\s+(.*)$');
    final match = regex.firstMatch(raw);
    if (match == null) {
      return IngredientPortion(
        name: raw.trim(),
        quantityBase: 1.0,
        unitKind: UnitKind.unit,
      );
    }

    final numStr = match.group(1) ?? '1';
    final unitStr = (match.group(2) ?? '').toLowerCase();
    final nameStr = match.group(3)?.trim() ?? raw.trim();

    final quantity = double.tryParse(numStr.replaceAll(',', '.')) ?? 1.0;
    final unitInfo = _unitFromString(unitStr);

    final quantityBase = quantity * unitInfo.multiplier;
    return IngredientPortion(
      name: nameStr,
      quantityBase: quantityBase,
      unitKind: unitInfo.kind,
    );
  }

  _UnitInfo _unitFromString(String unit) {
    // Peso
    if (unit == 'kg' || unit == 'kilos' || unit == 'kilogramo' || unit == 'kilogramos') {
      return _UnitInfo(kind: UnitKind.weight, multiplier: 1000.0);
    }
    if (unit == 'g' || unit == 'gr' || unit == 'gramo' || unit == 'gramos') {
      return _UnitInfo(kind: UnitKind.weight, multiplier: 1.0);
    }

    // Volumen
    if (unit == 'l' || unit == 'lt' || unit == 'litro' || unit == 'litros') {
      return _UnitInfo(kind: UnitKind.volume, multiplier: 1000.0);
    }
    if (unit == 'ml' || unit == 'cc') {
      return _UnitInfo(kind: UnitKind.volume, multiplier: 1.0);
    }

    // Unidades
    if (unit == 'ud' || unit == 'uds' || unit == 'unidad' || unit == 'unidades' || unit == 'pz' || unit == 'pieza') {
      return _UnitInfo(kind: UnitKind.unit, multiplier: 1.0);
    }

    // Desconocido -> unidad
    return _UnitInfo(kind: UnitKind.unit, multiplier: 1.0);
  }
}

class _UnitInfo {
  final UnitKind kind;
  final double multiplier;
  _UnitInfo({required this.kind, required this.multiplier});
}