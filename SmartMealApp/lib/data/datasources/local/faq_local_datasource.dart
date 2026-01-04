import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/data/models/faq_model.dart';

/// Datasource local para cachear FAQs por idioma.
///
/// Responsabilidad:
/// - Cachear FAQs en SharedPreferences
/// - Soportar múltiples idiomas (es, en)
/// - Cargar instantáneamente mientras carga Firestore
///
/// Estrategia de caché:
/// - Caché separado por locale: 'faq_cache_es', 'faq_cache_en'
/// - Al cambiar idioma, carga caché del nuevo idioma
/// - Si no hay caché, carga desde Firestore y cachea
///
/// Uso típico:
/// 1. Usuario abre pantalla soporte
/// 2. Muestra FAQs cacheadas (instantáneo)
/// 3. Carga desde Firestore en background
/// 4. Actualiza caché y UI si hay cambios
///
/// Claves:
/// - 'faq_cache_es': FAQs en español
/// - 'faq_cache_en': FAQs en inglés
///
/// Uso:
/// ```dart
/// final ds = FAQLocalDatasource(prefs);
///
/// // Cargar caché para español
/// final cached = await ds.getLatest('es');
/// if (cached != null) {
///   // Mostrar FAQs cacheadas
/// }
///
/// // Actualizar con datos de Firestore
/// final faqs = await firestoreDS.getFAQs('es');
/// await ds.saveLatest(faqs, 'es');
/// ```
class FAQLocalDatasource {
  static const String _keyPrefix = 'faq_cache_';

  final SharedPreferences _prefs;

  FAQLocalDatasource(this._prefs);

  /// Obtiene FAQs cacheadas para un idioma.
  ///
  /// Parámetros:
  /// - **locale**: código de idioma ('es', 'en')
  ///
  /// Retorna null si no hay caché o error.
  Future<List<FAQModel>?> getLatest(String locale) async {
    try {
      final key = '$_keyPrefix$locale';
      final cached = _prefs.getString(key);

      if (cached == null) {
        return null;
      }

      final decoded = jsonDecode(cached) as List<dynamic>;
      return decoded
          .map(
            (item) => FAQModel.fromMap(
              item as Map<String, dynamic>,
              item['id'] as String,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error al cargar FAQs del caché: $e');
      return null;
    }
  }

  /// Guarda FAQs en caché para un idioma.
  ///
  /// Parámetros:
  /// - **faqs**: lista de FAQModel
  /// - **locale**: código de idioma ('es', 'en')
  Future<void> saveLatest(List<FAQModel> faqs, String locale) async {
    try {
      final key = '$_keyPrefix$locale';
      final encoded = jsonEncode(faqs.map((faq) => _toJson(faq)).toList());
      await _prefs.setString(key, encoded);
    } catch (e) {
      debugPrint('Error al guardar FAQs en caché: $e');
    }
  }

  /// Limpia el caché de FAQs para un locale específico
  Future<void> clear(String locale) async {
    try {
      final key = '$_keyPrefix$locale';
      await _prefs.remove(key);
    } catch (e) {
      debugPrint('Error al limpiar caché de FAQs: $e');
    }
  }

  /// Limpia todos los cachés de FAQs (todos los idiomas).
  ///
  /// Se usa al actualizar FAQs en Firestore.
  Future<void> clearAll() async {
    try {
      final keys = _prefs.getKeys().toList();
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error al limpiar todos los cachés de FAQs: $e');
    }
  }

  /// Convierte FAQModel a JSON
  Map<String, dynamic> _toJson(FAQModel model) {
    return {
      'id': model.id,
      'question_es': model.questionEs,
      'answer_es': model.answerEs,
      'question_en': model.questionEn,
      'answer_en': model.answerEn,
      'order': model.order,
    };
  }
}
