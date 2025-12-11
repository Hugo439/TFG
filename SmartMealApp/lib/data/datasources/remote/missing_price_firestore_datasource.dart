import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/missing_price_entry_model.dart';

/// Datasource para tracking de precios faltantes en Firestore
class MissingPriceFirestoreDatasource {
  final FirebaseFirestore _firestore;

  MissingPriceFirestoreDatasource(this._firestore);

  static const String _collection = 'missing_prices';

  Future<void> trackMissingPrice(MissingPriceEntryModel model) async {
    try {
      final docRef = _firestore.collection(_collection).doc(model.normalizedName);
      final doc = await docRef.get();

      if (doc.exists) {
        // Incrementar contador
        final existingModel = MissingPriceEntryModel.fromFirestore(doc.data()!, doc.id);
        await docRef.update({
          'requestCount': existingModel.requestCount + 1,
          'lastRequested': DateTime.now().toIso8601String(),
        });

        if (kDebugMode) {
          print('📊 [MissingPriceDatasource] Incrementado contador: ${model.normalizedName}');
        }
      } else {
        // Crear nuevo registro
        await docRef.set(model.toFirestore());

        if (kDebugMode) {
          print('📊 [MissingPriceDatasource] Nuevo registro: ${model.normalizedName}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceDatasource] Error tracking: $e');
      }
      rethrow;
    }
  }

  Future<List<MissingPriceEntryModel>> getTopMissingPrices({int limit = 20}) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .orderBy('requestCount', descending: true)
          .limit(limit)
          .get();

      if (kDebugMode) {
        print('📊 [MissingPriceDatasource] Top ${query.docs.length} precios faltantes');
      }

      return query.docs
          .map((doc) => MissingPriceEntryModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceDatasource] Error obteniendo top missing: $e');
      }
      rethrow;
    }
  }

  Future<List<MissingPriceEntryModel>> getAllMissingPrices() async {
    try {
      final query = await _firestore
          .collection(_collection)
          .orderBy('requestCount', descending: true)
          .get();

      return query.docs
          .map((doc) => MissingPriceEntryModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceDatasource] Error obteniendo all missing: $e');
      }
      rethrow;
    }
  }

  Future<void> removeMissingPrice(String normalizedName) async {
    try {
      await _firestore.collection(_collection).doc(normalizedName).delete();

      if (kDebugMode) {
        print('🗑️ [MissingPriceDatasource] Eliminado: $normalizedName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceDatasource] Error eliminando: $e');
      }
      rethrow;
    }
  }
}
