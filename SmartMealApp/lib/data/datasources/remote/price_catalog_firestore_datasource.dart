import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/price_entry_model.dart';

/// Datasource para el catálogo de precios en Firestore.
///
/// Colección: 'price_catalog'
///
/// Responsabilidades:
/// - CRUD de precios de referencia del catálogo global
/// - Búsqueda de precios por nombre normalizado
/// - Búsqueda por categoría
/// - Búsqueda de texto completo (lado cliente)
///
/// Estructura del documento:
/// ```
/// price_catalog/{normalizedName}
///   - displayName: string ("Pollo pechuga")
///   - category: string ("carnes_y_pescados")
///   - priceRef: number (8.0 €/kg)
///   - unitKind: string ('weight', 'liter', 'piece')
/// ```
///
/// Normalización:
/// - ID del documento: nombre normalizado ("pollo" en lugar de "Pollo pechuga")
/// - Sin tildes, minúsculas, sin espacios
/// - Ejemplo: "Pollo pechuga" → "pollo"
///
/// Búsqueda de texto:
/// - Firestore no tiene búsqueda de texto nativo
/// - searchPrices() descarga todos los docs y filtra en cliente
/// - Busca en normalizedName (id) y displayName
///
/// Logging:
/// - Solo en debug mode
/// - Prefijo: 📦 para operaciones normales, ❌ para errores
///
/// Uso:
/// ```dart
/// final ds = PriceCatalogFirestoreDatasource(firestore);
///
/// // Buscar por nombre normalizado
/// final entry = await ds.getPriceEntry('pollo');
///
/// // Buscar por categoría
/// final meats = await ds.getPricesByCategory('carnes_y_pescados');
///
/// // Búsqueda de texto
/// final results = await ds.searchPrices('pech'); // encuentra "Pollo pechuga"
/// ```
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
