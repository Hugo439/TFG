import 'package:smartmeal/domain/entities/user_price_override.dart';

/// Modelo de datos para precio personalizado de ingrediente.
///
/// Responsabilidad:
/// - Persistir precios personalizados del usuario en Firestore
/// - Convertir entre modelo y entidad del dominio
///
/// Casos de uso:
/// - Usuario edita precio de "Pollo" a 5.50€/kg
/// - Sistema usa precio personalizado en lugar del catálogo
///
/// Campos:
/// - **userId**: propietario del override
/// - **ingredientId**: ingrediente normalizado ("pollo")
/// - **customPrice**: precio en euros
/// - **reason**: motivo opcional ("Mi tienda", "Oferta")
/// - **createdAt**: timestamp ISO 8601
///
/// Ruta Firestore:
/// ```
/// users/{userId}/price_overrides/{ingredientId}
/// ```
///
/// Ejemplo:
/// ```json
/// {
///   "customPrice": 5.50,
///   "reason": "Precio en mi supermercado",
///   "createdAt": "2024-01-15T10:30:00.000Z"
/// }
/// ```
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

  /// Crea modelo desde DocumentSnapshot de Firestore.
  ///
  /// userId e ingredientId vienen del path del documento.
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

  /// Convierte a Map para persistencia en Firestore.
  ///
  /// No incluye userId/ingredientId (están en el path).
  Map<String, dynamic> toFirestore() {
    return {
      'customPrice': customPrice,
      if (reason != null) 'reason': reason,
      'createdAt': createdAt,
    };
  }

  /// Convierte modelo a entidad del dominio.
  ///
  /// Parsea createdAt de ISO 8601 a DateTime.
  UserPriceOverride toEntity() {
    return UserPriceOverride(
      userId: userId,
      ingredientId: ingredientId,
      customPrice: customPrice,
      reason: reason,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Crea modelo desde entidad del dominio.
  ///
  /// Convierte createdAt DateTime a ISO 8601 string.
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
