import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// Entrada del catálogo de precios editable en Firestore
class PriceEntry {
  final String id; // Nombre normalizado
  final String displayName; // Nombre para mostrar
  final String category;
  final UnitKind unitKind;
  final double priceRef; // Precio de referencia (€/kg, €/L, €/ud)
  final String? brand; // Marca opcional
  final DateTime lastUpdated;

  const PriceEntry({
    required this.id,
    required this.displayName,
    required this.category,
    required this.unitKind,
    required this.priceRef,
    this.brand,
    required this.lastUpdated,
  });

  factory PriceEntry.fromMap(Map<String, dynamic> map, String id) {
    return PriceEntry(
      id: id,
      displayName: map['displayName'] as String? ?? id,
      category: map['category'] as String,
      unitKind: UnitKindExtension.fromFirestore(
        map['unitKind'] as String? ?? 'weight',
      ),
      priceRef: (map['priceRef'] as num).toDouble(),
      brand: map['brand'] as String?,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'category': category,
      'unitKind': unitKind.toFirestore(),
      'priceRef': priceRef,
      if (brand != null) 'brand': brand,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  PriceEntry copyWith({
    String? displayName,
    String? category,
    UnitKind? unitKind,
    double? priceRef,
    String? brand,
    DateTime? lastUpdated,
  }) {
    return PriceEntry(
      id: id,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      unitKind: unitKind ?? this.unitKind,
      priceRef: priceRef ?? this.priceRef,
      brand: brand ?? this.brand,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'PriceEntry(id: $id, price: €$priceRef/${unitKind.largeUnit}, brand: $brand)';
}
