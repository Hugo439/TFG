import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/price_entry_model.dart';

/// Datasource para el catálogo de precios en Firestore
class PriceCatalogFirestoreDatasource {
  final FirebaseFirestore _firestore;

  PriceCatalogFirestoreDatasource(this._firestore);

  static const String _collection = 'price_catalog';

  Future<PriceEntryModel?> getPriceEntry(String normalizedName) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(normalizedName)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('📦 [PriceCatalogDatasource] No existe: $normalizedName');
        }
        return null;
      }

      return PriceEntryModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ [PriceCatalogDatasource] Error obteniendo $normalizedName: $e',
        );
      }
      rethrow;
    }
  }

  Future<List<PriceEntryModel>> getPricesByCategory(String category) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();

      if (kDebugMode) {
        print(
          '📦 [PriceCatalogDatasource] Obtenidos ${query.docs.length} precios para $category',
        );
      }

      return query.docs
          .map((doc) => PriceEntryModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ [PriceCatalogDatasource] Error obteniendo categoría $category: $e',
        );
      }
      rethrow;
    }
  }

  Future<List<PriceEntryModel>> searchPrices(String searchTerm) async {
    try {
      // Firestore no soporta búsqueda de texto completo nativa
      // Obtenemos todos y filtramos en cliente
      final query = await _firestore.collection(_collection).get();

      final results = query.docs
          .where((doc) {
            final name = doc.id.toLowerCase();
            final displayName = (doc.data()['displayName'] as String? ?? '')
                .toLowerCase();
            final term = searchTerm.toLowerCase();
            return name.contains(term) || displayName.contains(term);
          })
          .map((doc) => PriceEntryModel.fromFirestore(doc.data(), doc.id))
          .toList();

      if (kDebugMode) {
        print(
          '🔍 [PriceCatalogDatasource] Búsqueda "$searchTerm": ${results.length} resultados',
        );
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceCatalogDatasource] Error buscando "$searchTerm": $e');
      }
      rethrow;
    }
  }

  Future<void> savePriceEntry(PriceEntryModel model) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(model.id)
          .set(model.toFirestore());

      if (kDebugMode) {
        print('💾 [PriceCatalogDatasource] Guardado: ${model.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceCatalogDatasource] Error guardando ${model.id}: $e');
      }
      rethrow;
    }
  }

  Future<void> deletePriceEntry(String normalizedName) async {
    try {
      await _firestore.collection(_collection).doc(normalizedName).delete();

      if (kDebugMode) {
        print('🗑️ [PriceCatalogDatasource] Eliminado: $normalizedName');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ [PriceCatalogDatasource] Error eliminando $normalizedName: $e',
        );
      }
      rethrow;
    }
  }
}
