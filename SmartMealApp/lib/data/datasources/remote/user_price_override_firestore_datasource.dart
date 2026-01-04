import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/user_price_override_model.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Datasource para overrides de precio del usuario en Firestore.
///
/// Ruta: users/{userId}/price_overrides/{ingredientId}
///
/// Responsabilidades:
/// - CRUD de precios personalizados por usuario
/// - Sobrescribir precios del catálogo global
///
/// Estructura del documento:
/// ```
/// users/{userId}/price_overrides/{ingredientId}
///   - ingredientId: string ("pollo")
///   - customPrice: number (5.5 €/kg)
///   - createdAt: string (ISO8601)
///   - updatedAt: string (ISO8601)
/// ```
///
/// Prioridad en PriceDatabaseService:
/// 1. **UserPriceOverride** (personalizado) ← ESTE DATASOURCE
/// 2. PriceEntry (catálogo global)
/// 3. Fallback por categoría
///
/// Flujo típico:
/// 1. Usuario ve precio estimado de "pollo" (8.0€/kg del catálogo)
/// 2. Usuario edita precio a 5.50€/kg (precio de su supermercado)
/// 3. saveUserPriceOverride() guarda en Firestore
/// 4. PriceDatabaseService usa 5.50€/kg para este usuario
/// 5. Estimaciones futuras usan el precio personalizado
///
/// Logging:
/// - Solo en debug mode
/// - Prefijo: 💾 para guardado, ❌ para errores
///
/// Uso:
/// ```dart
/// final ds = UserPriceFirestoreDatasource(firestore);
///
/// // Guardar precio personalizado
/// await ds.saveUserPriceOverride(UserPriceOverrideModel(
///   userId: 'user123',
///   ingredientId: 'pollo',
///   customPrice: 5.50,
/// ));
///
/// // Obtener override
/// final override = await ds.getUserPriceOverride(
///   userId: 'user123',
///   ingredientId: 'pollo',
/// ); // 5.50€/kg
///
/// // Eliminar override (volver al catálogo)
/// await ds.deleteUserPriceOverride(
///   userId: 'user123',
///   ingredientId: 'pollo',
/// );
/// ```
class UserPriceFirestoreDatasource {
  final FirebaseFirestore _firestore;

  UserPriceFirestoreDatasource(this._firestore);

  Future<UserPriceOverrideModel?> getUserPriceOverride({
    required String userId,
    required String ingredientId,
  }) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionUserPriceOverrides)
          .doc(ingredientId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserPriceOverrideModel.fromFirestore(
        doc.data()!,
        userId,
        ingredientId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceDatasource] Error obteniendo override: $e');
      }
      rethrow;
    }
  }

  Future<List<UserPriceOverrideModel>> getAllUserOverrides(
    String userId,
  ) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionUserPriceOverrides)
          .get();

      return query.docs
          .map(
            (doc) => UserPriceOverrideModel.fromFirestore(
              doc.data(),
              userId,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ [UserPriceDatasource] Error obteniendo overrides del usuario: $e',
        );
      }
      rethrow;
    }
  }

  Future<void> saveUserPriceOverride(UserPriceOverrideModel model) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(model.userId)
          .collection(AppConstants.collectionUserPriceOverrides)
          .doc(model.ingredientId)
          .set(model.toFirestore());

      if (kDebugMode) {
        print(
          '💾 [UserPriceDatasource] Override guardado: ${model.ingredientId}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceDatasource] Error guardando override: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteUserPriceOverride({
    required String userId,
    required String ingredientId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionUserPriceOverrides)
          .doc(ingredientId)
          .delete();

      if (kDebugMode) {
        print('🗑️ [UserPriceDatasource] Override eliminado: $ingredientId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceDatasource] Error eliminando override: $e');
      }
      rethrow;
    }
  }
}
