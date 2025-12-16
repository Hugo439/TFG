import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/models/day_menu_model.dart';

class WeeklyMenuLocalDatasource {
  static const String _key = 'latest_weekly_menu_cache';
  final SharedPreferences _prefs;

  WeeklyMenuLocalDatasource(this._prefs);

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
        updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt'] as String) : null,
        days: (j['days'] as List<dynamic>).map((e) => _dayFromJson(e as Map<String, dynamic>)).toList(),
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
