import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/models/day_menu_model.dart';

/// Datasource local para cachear último menú semanal.
///
/// Responsabilidad:
/// - Cachear último menú cargado en SharedPreferences
/// - Mostrar instantáneamente mientras carga Firestore
///
/// Estrategia:
/// - Solo cachea el menú más reciente
/// - Al abrir app, muestra caché instantáneamente
/// - Carga lista completa desde Firestore en background
/// - Actualiza caché con menú más reciente
///
/// Serialización:
/// - WeeklyMenuModel → JSON con:
///   - Metadatos del menú
///   - Lista de 7 DayMenuModel
///   - IDs de recetas (no objetos completos)
///
/// Limitaciones:
/// - Solo cachea 1 menú (el último)
/// - Para múltiples menús, cargar desde Firestore
///
/// Clave: 'latest_weekly_menu_cache'
///
/// Uso:
/// ```dart
/// final ds = WeeklyMenuLocalDatasource(prefs);
///
/// // Mostrar caché instantáneamente
/// final cached = await ds.getLatest();
/// if (cached != null) {
///   // Mostrar menú cacheado
/// }
///
/// // Cargar desde Firestore
/// final menus = await firestoreDS.getWeeklyMenus();
/// if (menus.isNotEmpty) {
///   await ds.saveLatest(menus.first);
/// }
/// ```
class WeeklyMenuLocalDatasource {
  static const String _key = 'latest_weekly_menu_cache';
  final SharedPreferences _prefs;

  WeeklyMenuLocalDatasource(this._prefs);

  /// Obtiene último menú cacheado.
  ///
  /// Retorna null si:
  /// - No hay caché
  /// - Error al parsear JSON
  ///
  /// Se usa para mostrar instantáneamente al abrir app.
  Future<WeeklyMenuModel?> getLatest() async {
    try {
      final jsonStr = _prefs.getString(_key);
      if (jsonStr == null) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _fromJson(map);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [WeeklyMenuLocalDS] Error leyendo caché: $e');
      }
      return null;
    }
  }

  /// Guarda menú en caché.
  ///
  /// Reemplaza caché anterior (solo guarda 1 menú).
  ///
  /// Se llama con el menú más reciente después de
  /// cargar desde Firestore.
  Future<void> saveLatest(WeeklyMenuModel menu) async {
    try {
      final map = _toJson(menu);
      final jsonStr = jsonEncode(map);
      await _prefs.setString(_key, jsonStr);
      if (kDebugMode) {
        print('💾 [WeeklyMenuLocalDS] Último menú cacheado: ${menu.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [WeeklyMenuLocalDS] Error guardando caché: $e');
      }
    }
  }

  /// Limpia caché de menú.
  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  // ==== JSON helpers ====
  Map<String, dynamic> _toJson(WeeklyMenuModel m) => {
    'id': m.id,
    'userId': m.userId,
    'name': m.name,
    'weekStartDate': m.weekStartDate.toIso8601String(),
    'createdAt': m.createdAt.toIso8601String(),
    'updatedAt': m.updatedAt?.toIso8601String(),
    'days': m.days.map((d) => _dayToJson(d)).toList(),
  };

  WeeklyMenuModel _fromJson(Map<String, dynamic> j) => WeeklyMenuModel(
    id: j['id'] as String? ?? '',
    userId: j['userId'] as String? ?? '',
    name: j['name'] as String?,
    weekStartDate: DateTime.parse(j['weekStartDate'] as String),
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: j['updatedAt'] != null
        ? DateTime.parse(j['updatedAt'] as String)
        : null,
    days: (j['days'] as List<dynamic>)
        .map((e) => _dayFromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> _dayToJson(DayMenuModel d) => {
    'day': d.day,
    'recipes': d.recipes.map((r) => r).toList(),
  };

  DayMenuModel _dayFromJson(Map<String, dynamic> j) => DayMenuModel(
    day: j['day'] as String,
    recipes: List<String>.from(j['recipes'] as List<dynamic>? ?? const []),
  );
}
