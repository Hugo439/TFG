/// Tipo de unidad para cantidades de ingredientes
enum UnitKind {
  weight, // gramos/kg
  volume, // ml/L
  unit, // unidades/piezas
}

extension UnitKindExtension on UnitKind {
  /// Convierte a string para almacenamiento
  String toFirestore() {
    switch (this) {
      case UnitKind.weight:
        return 'weight';
      case UnitKind.volume:
        return 'volume';
      case UnitKind.unit:
        return 'unit';
    }
  }

  /// Crea desde string de Firestore
  static UnitKind fromFirestore(String value) {
    switch (value) {
      case 'weight':
        return UnitKind.weight;
      case 'volume':
        return UnitKind.volume;
      case 'unit':
        return UnitKind.unit;
      default:
        return UnitKind.unit;
    }
  }

  /// Label en español
  String get displayName {
    switch (this) {
      case UnitKind.weight:
        return 'Peso';
      case UnitKind.volume:
        return 'Volumen';
      case UnitKind.unit:
        return 'Unidades';
    }
  }

  /// Unidad base
  String get baseUnit {
    switch (this) {
      case UnitKind.weight:
        return 'g';
      case UnitKind.volume:
        return 'ml';
      case UnitKind.unit:
        return 'uds';
    }
  }

  /// Unidad grande
  String get largeUnit {
    switch (this) {
      case UnitKind.weight:
        return 'kg';
      case UnitKind.volume:
        return 'L';
      case UnitKind.unit:
        return 'uds';
    }
  }

  /// Factor de conversión a unidad grande
  double get conversionFactor {
    switch (this) {
      case UnitKind.weight:
        return 1000.0; // 1kg = 1000g
      case UnitKind.volume:
        return 1000.0; // 1L = 1000ml
      case UnitKind.unit:
        return 1.0;
    }
  }
}
