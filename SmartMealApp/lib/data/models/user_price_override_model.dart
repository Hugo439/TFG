import 'package:smartmeal/domain/entities/user_price_override.dart';

/// Modelo de datos para UserPriceOverride (capa de datos)
class UserPriceOverrideModel {
  final String userId;
  final String ingredientId;
  final double customPrice;
  final String? reason;
  final String createdAt;

  const UserPriceOverrideModel({
    required this.userId,
    required this.ingredientId,
    required this.customPrice,
    this.reason,
    required this.createdAt,
  });

  factory UserPriceOverrideModel.fromFirestore(
    Map<String, dynamic> map,
    String userId,
    String ingredientId,
  ) {
    return UserPriceOverrideModel(
      userId: userId,
      ingredientId: ingredientId,
      customPrice: (map['customPrice'] as num).toDouble(),
      reason: map['reason'] as String?,
      createdAt:
          map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customPrice': customPrice,
      if (reason != null) 'reason': reason,
      'createdAt': createdAt,
    };
  }

  UserPriceOverride toEntity() {
    return UserPriceOverride(
      userId: userId,
      ingredientId: ingredientId,
      customPrice: customPrice,
      reason: reason,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory UserPriceOverrideModel.fromEntity(UserPriceOverride entity) {
    return UserPriceOverrideModel(
      userId: entity.userId,
      ingredientId: entity.ingredientId,
      customPrice: entity.customPrice,
      reason: entity.reason,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
