import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/data/models/statistics_cache_model.dart';

/// Datasource local para cachear estadísticas del menú.
///
/// Responsabilidad:
/// - Cachear estadísticas en SharedPreferences
/// - Evitar recalcular estadísticas cada vez
///
/// Estrategia:
/// 1. Calcular estadísticas (proceso costoso):
///    - Recorre todas las recetas del menú
///    - Agrega ingredientes, calorías, macros
///    - Calcula coste estimado
///
/// 2. Guardar en caché local:
///    - Caché incluye menuDate para validación
///    - Si menuDate cambia, caché inválido
///
/// 3. Cargar desde caché:
///    - Si menuDate coincide, usar caché
///    - Si no, recalcular
///
/// Validación de caché:
/// - StatisticsRepository verifica menuDate
/// - Si menú modificado, limpia caché
///
/// Clave: 'latest_statistics_cache'
///
/// Uso:
/// ```dart
/// final ds = StatisticsLocalDatasource(prefs);
///
/// // Intentar cargar caché
/// final cached = await ds.getLatest();
/// if (cached != null && cached.menuDate == currentMenuDate) {
///   return cached.toSummary();
/// }
///
/// // Si no válido, recalcular y cachear
/// final summary = await calculateStatistics();
/// final cache = StatisticsCacheModel.fromSummary(summary, menuDate);
/// await ds.saveLatest(cache);
/// ```
class StatisticsLocalDatasource {
  static const String _key = 'latest_statistics_cache';
  final SharedPreferences _prefs;

  StatisticsLocalDatasource(this._prefs);

  /// Obtiene estadísticas cacheadas.
  ///
  /// Retorna null si:
  /// - No hay caché
  /// - Error al parsear JSON
  ///
  /// Caller debe validar menuDate.
  Future<StatisticsCacheModel?> getLatest() async {
    try {
      final jsonStr = _prefs.getString(_key);
      if (jsonStr == null) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return StatisticsCacheModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Guarda estadísticas en caché.
  ///
  /// Incluye menuDate para validación posterior.
  /// Errores silenciados (caché no crítico).
  Future<void> saveLatest(StatisticsCacheModel stats) async {
    try {
      final map = stats.toJson();
      final jsonStr = jsonEncode(map);
      await _prefs.setString(_key, jsonStr);
    } catch (e) {
      // Silenciar errores de caché, no debe impedir la operación
    }
  }

  /// Limpia caché de estadísticas.
  ///
  /// Se llama al modificar menú.
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
