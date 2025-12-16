import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/data/models/faq_model.dart';

/// Datasource local para cachear FAQs en SharedPreferences
class FAQLocalDatasource {
  static const String _keyPrefix = 'faq_cache_';
  
  final SharedPreferences _prefs;

  FAQLocalDatasource(this._prefs);

  /// Obtiene las FAQs cacheadas para un locale específico
  /// Retorna null si no hay caché disponible
  Future<List<FAQModel>?> getLatest(String locale) async {
    try {
      final key = '$_keyPrefix$locale';
      final cached = _prefs.getString(key);
      
      if (cached == null) {
        return null;
      }
      
      final decoded = jsonDecode(cached) as List<dynamic>;
      return decoded
          .map((item) => FAQModel.fromMap(
                item as Map<String, dynamic>,
                item['id'] as String,
              ))
          .toList();
    } catch (e) {
      print('Error al cargar FAQs del caché: $e');
      return null;
    }
  }

  /// Guarda una lista de FAQs en caché para un locale específico
  Future<void> saveLatest(List<FAQModel> faqs, String locale) async {
    try {
      final key = '$_keyPrefix$locale';
      final encoded = jsonEncode(faqs.map((faq) => _toJson(faq)).toList());
      await _prefs.setString(key, encoded);
    } catch (e) {
      print('Error al guardar FAQs en caché: $e');
    }
  }

  /// Limpia el caché de FAQs para un locale específico
  Future<void> clear(String locale) async {
    try {
      final key = '$_keyPrefix$locale';
      await _prefs.remove(key);
    } catch (e) {
      print('Error al limpiar caché de FAQs: $e');
    }
  }

  /// Limpia todos los cachés de FAQs
  Future<void> clearAll() async {
    try {
      final keys = _prefs.getKeys().toList();
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error al limpiar todos los cachés de FAQs: $e');
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
