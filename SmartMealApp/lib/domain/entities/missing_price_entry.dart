import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// Registro de ingredientes sin precio para analytics
class MissingPriceEntry {
  final String ingredientName;
  final String normalizedName;
  final String category;
  final UnitKind unitKind;
  final int requestCount;
  final DateTime firstRequested;
  final DateTime lastRequested;

  const MissingPriceEntry({
    required this.ingredientName,
    required this.normalizedName,
    required this.category,
    required this.unitKind,
    required this.requestCount,
    required this.firstRequested,
    required this.lastRequested,
  });

  factory MissingPriceEntry.fromMap(Map<String, dynamic> map, String id) {
    return MissingPriceEntry(
      ingredientName: map['ingredientName'] as String? ?? id,
      normalizedName: id,
      category: map['category'] as String,
      unitKind: UnitKindExtension.fromFirestore(
        map['unitKind'] as String? ?? 'weight',
      ),
      requestCount: map['requestCount'] as int? ?? 1,
      firstRequested: map['firstRequested'] != null
          ? DateTime.parse(map['firstRequested'] as String)
          : DateTime.now(),
      lastRequested: map['lastRequested'] != null
          ? DateTime.parse(map['lastRequested'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientName': ingredientName,
      'category': category,
      'unitKind': unitKind.toFirestore(),
      'requestCount': requestCount,
      'firstRequested': firstRequested.toIso8601String(),
      'lastRequested': lastRequested.toIso8601String(),
    };
  }

  MissingPriceEntry incrementCount() {
    return MissingPriceEntry(
      ingredientName: ingredientName,
      normalizedName: normalizedName,
      category: category,
      unitKind: unitKind,
      requestCount: requestCount + 1,
      firstRequested: firstRequested,
      lastRequested: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'MissingPriceEntry(name: $ingredientName, requests: $requestCount)';
}
