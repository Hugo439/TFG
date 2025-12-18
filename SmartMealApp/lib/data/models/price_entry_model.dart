import 'package:smartmeal/domain/entities/price_entry.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// Modelo de datos para PriceEntry (capa de datos)
class PriceEntryModel {
  final String id;
  final String displayName;
  final String category;
  final String unitKind;
  final double priceRef;
  final String? brand;
  final String lastUpdated;

  const PriceEntryModel({
    required this.id,
    required this.displayName,
    required this.category,
    required this.unitKind,
    required this.priceRef,
    this.brand,
    required this.lastUpdated,
  });

  factory PriceEntryModel.fromFirestore(Map<String, dynamic> map, String id) {
    return PriceEntryModel(
      id: id,
      displayName: map['displayName'] as String? ?? id,
      category: map['category'] as String,
      unitKind: map['unitKind'] as String? ?? 'weight',
      priceRef: (map['priceRef'] as num).toDouble(),
      brand: map['brand'] as String?,
      lastUpdated:
          map['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'category': category,
      'unitKind': unitKind,
      'priceRef': priceRef,
      if (brand != null) 'brand': brand,
      'lastUpdated': lastUpdated,
    };
  }

  PriceEntry toEntity() {
    return PriceEntry(
      id: id,
      displayName: displayName,
      category: category,
      unitKind: UnitKindExtension.fromFirestore(unitKind),
      priceRef: priceRef,
      brand: brand,
      lastUpdated: DateTime.parse(lastUpdated),
    );
  }

  factory PriceEntryModel.fromEntity(PriceEntry entity) {
    return PriceEntryModel(
      id: entity.id,
      displayName: entity.displayName,
      category: entity.category,
      unitKind: entity.unitKind.toFirestore(),
      priceRef: entity.priceRef,
      brand: entity.brand,
      lastUpdated: entity.lastUpdated.toIso8601String(),
    );
  }
}
