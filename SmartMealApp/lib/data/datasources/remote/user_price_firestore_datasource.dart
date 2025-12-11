import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/user_price_override_model.dart';

/// Datasource para overrides de precio del usuario en Firestore
class UserPriceFirestoreDatasource {
  final FirebaseFirestore _firestore;

  UserPriceFirestoreDatasource(this._firestore);

  Future<UserPriceOverrideModel?> getUserPriceOverride({
    required String userId,
    required String ingredientId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('user_price_overrides')
          .doc(ingredientId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserPriceOverrideModel.fromFirestore(doc.data()!, userId, ingredientId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceDatasource] Error obteniendo override: $e');
      }
      rethrow;
    }
  }

  Future<List<UserPriceOverrideModel>> getAllUserOverrides(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('user_price_overrides')
          .get();

      return query.docs
          .map((doc) => UserPriceOverrideModel.fromFirestore(doc.data(), userId, doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceDatasource] Error obteniendo overrides del usuario: $e');
      }
      rethrow;
    }
  }

  Future<void> saveUserPriceOverride(UserPriceOverrideModel model) async {
    try {
      await _firestore
          .collection('users')
          .doc(model.userId)
          .collection('user_price_overrides')
          .doc(model.ingredientId)
          .set(model.toFirestore());

      if (kDebugMode) {
        print('💾 [UserPriceDatasource] Override guardado: ${model.ingredientId}');
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
          .collection('users')
          .doc(userId)
          .collection('user_price_overrides')
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
