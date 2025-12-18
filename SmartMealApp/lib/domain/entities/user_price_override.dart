/// Override de precio personalizado por el usuario
class UserPriceOverride {
  final String userId;
  final String ingredientId; // Nombre normalizado
  final double customPrice;
  final String? reason; // Ej: "Compro en mercado local"
  final DateTime createdAt;

  const UserPriceOverride({
    required this.userId,
    required this.ingredientId,
    required this.customPrice,
    this.reason,
    required this.createdAt,
  });

  factory UserPriceOverride.fromMap(
    Map<String, dynamic> map,
    String userId,
    String ingredientId,
  ) {
    return UserPriceOverride(
      userId: userId,
      ingredientId: ingredientId,
      customPrice: (map['customPrice'] as num).toDouble(),
      reason: map['reason'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customPrice': customPrice,
      if (reason != null) 'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'UserPriceOverride(ingredient: $ingredientId, price: €$customPrice, reason: $reason)';
}
