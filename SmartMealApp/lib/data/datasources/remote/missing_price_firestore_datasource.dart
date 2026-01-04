import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/missing_price_entry_model.dart';

/// Datasource para tracking de precios faltantes en Firestore.
///
/// Colección: 'missing_prices'
///
/// Responsabilidades:
/// - Registrar ingredientes sin precio en el catálogo
/// - Contar solicitudes para priorizar adiciones
/// - Listar ingredientes faltantes ordenados por popularidad
///
/// Estructura del documento:
/// ```
/// missing_prices/{normalizedName}
///   - normalizedName: string ("aguacate")
///   - displayName: string ("Aguacate")
///   - category: string ("frutas_y_verduras")
///   - requestCount: number (5)
///   - lastRequested: string (ISO8601)
/// ```
///
/// Flujo típico:
/// 1. Usuario genera menú con "aguacate"
/// 2. PriceDatabaseService no encuentra precio en catalog
/// 3. trackMissingPrice() se llama:
///    - Si existe: incrementa requestCount
///    - Si no existe: crea nuevo doc con requestCount=1
/// 4. Admin consulta getTopMissingPrices(20)
/// 5. Admin añade "aguacate" al price_catalog
/// 6. removeMissingPrice("aguacate")
///
/// Ordenamiento:
/// - getTopMissingPrices: por requestCount descendente
/// - getAllMissingPrices: por requestCount descendente
///
/// Logging:
/// - Solo en debug mode
/// - Prefijo: 📊 para operaciones normales, ❌ para errores
///
/// Uso:
/// ```dart
/// final ds = MissingPriceFirestoreDatasource(firestore);
///
/// // Registrar ingrediente faltante
/// await ds.trackMissingPrice(MissingPriceEntryModel(...));
///
/// // Ver top 20 más solicitados
/// final top = await ds.getTopMissingPrices(limit: 20);
/// // [{"aguacate": 15 requests}, {"quinoa": 8 requests}, ...]
/// ```
class MissingPriceFirestoreDatasource {
  final FirebaseFirestore _firestore;

  MissingPriceFirestoreDatasource(this._firestore);

  static const String _collection = 'missing_prices';

  Future<void> trackMissingPrice(MissingPriceEntryModel model) async {
    try {
      final docRef = _firestore
          .collection(_collection)
          .doc(model.normalizedName);
      final doc = await docRef.get();

      if (doc.exists) {
        // Incrementar contador
        final existingModel = MissingPriceEntryModel.fromFirestore(
          doc.data()!,
          doc.id,
        );
        await docRef.update({
          'requestCount': existingModel.requestCount + 1,
          'lastRequested': DateTime.now().toIso8601String(),
        });

        if (kDebugMode) {
          print(
            '📊 [MissingPriceDatasource] Incrementado contador: ${model.normalizedName}',
          );
        }
      } else {
        // Crear nuevo registro
        await docRef.set(model.toFirestore());

        if (kDebugMode) {
          print(
            '📊 [MissingPriceDatasource] Nuevo registro: ${model.normalizedName}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceDatasource] Error tracking: $e');
      }
      rethrow;
    }
  }

  Future<List<MissingPriceEntryModel>> getTopMissingPrices({
    int limit = 20,
  }) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .orderBy('requestCount', descending: true)
          .limit(limit)
          .get();

      if (kDebugMode) {
        print(
          '📊 [MissingPriceDatasource] Top ${query.docs.length} precios faltantes',
        );
      }

      return query.docs
          .map(
            (doc) => MissingPriceEntryModel.fromFirestore(doc.data(), doc.id),
          )
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
          .map(
            (doc) => MissingPriceEntryModel.fromFirestore(doc.data(), doc.id),
          )
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
