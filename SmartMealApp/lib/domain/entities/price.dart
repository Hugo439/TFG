class PriceEntity {
  final String ingredientName;
  final String category;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;
  final String unit; // 'weight', 'liter', 'piece'
  final DateTime lastUpdated;

  const PriceEntity({
    required this.ingredientName,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    required this.unit,
    required this.lastUpdated,
  });

  factory PriceEntity.fromMap(Map<String, dynamic> map) {
    return PriceEntity(
      ingredientName: map['ingredientName'] as String,
      category: map['category'] as String,
      minPrice: (map['minPrice'] as num).toDouble(),
      maxPrice: (map['maxPrice'] as num).toDouble(),
      avgPrice: (map['avgPrice'] as num).toDouble(),
      unit: map['unit'] as String? ?? 'weight',
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientName': ingredientName,
      'category': category,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'avgPrice': avgPrice,
      'unit': unit,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'PriceEntity(ingredient: $ingredientName, category: $category, avg: €$avgPrice)';
}
