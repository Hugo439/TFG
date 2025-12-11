import 'package:smartmeal/domain/entities/missing_price_entry.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// Modelo de datos para MissingPriceEntry (capa de datos)
class MissingPriceEntryModel {
  final String normalizedName;
  final String ingredientName;
  final String category;
  final String unitKind;
  final int requestCount;
  final String firstRequested;
  final String lastRequested;

  const MissingPriceEntryModel({
    required this.normalizedName,
    required this.ingredientName,
    required this.category,
    required this.unitKind,
    required this.requestCount,
    required this.firstRequested,
    required this.lastRequested,
  });

  factory MissingPriceEntryModel.fromFirestore(Map<String, dynamic> map, String id) {
    return MissingPriceEntryModel(
      normalizedName: id,
      ingredientName: map['ingredientName'] as String? ?? id,
      category: map['category'] as String,
      unitKind: map['unitKind'] as String? ?? 'weight',
      requestCount: map['requestCount'] as int? ?? 1,
      firstRequested: map['firstRequested'] as String? ?? DateTime.now().toIso8601String(),
      lastRequested: map['lastRequested'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ingredientName': ingredientName,
      'category': category,
      'unitKind': unitKind,
      'requestCount': requestCount,
      'firstRequested': firstRequested,
      'lastRequested': lastRequested,
    };
  }

  MissingPriceEntry toEntity() {
    return MissingPriceEntry(
      ingredientName: ingredientName,
      normalizedName: normalizedName,
      category: category,
      unitKind: UnitKindExtension.fromFirestore(unitKind),
      requestCount: requestCount,
      firstRequested: DateTime.parse(firstRequested),
      lastRequested: DateTime.parse(lastRequested),
    );
  }

  factory MissingPriceEntryModel.fromEntity(MissingPriceEntry entity) {
    return MissingPriceEntryModel(
      normalizedName: entity.normalizedName,
      ingredientName: entity.ingredientName,
      category: entity.category,
      unitKind: entity.unitKind.toFirestore(),
      requestCount: entity.requestCount,
      firstRequested: entity.firstRequested.toIso8601String(),
      lastRequested: entity.lastRequested.toIso8601String(),
    );
  }
}
