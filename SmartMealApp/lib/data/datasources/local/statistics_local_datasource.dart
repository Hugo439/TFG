import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/data/models/statistics_cache_model.dart';

class StatisticsLocalDatasource {
  static const String _key = 'latest_statistics_cache';
  final SharedPreferences _prefs;

  StatisticsLocalDatasource(this._prefs);

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

  Future<void> saveLatest(StatisticsCacheModel stats) async {
    try {
      final map = stats.toJson();
      final jsonStr = jsonEncode(map);
      await _prefs.setString(_key, jsonStr);
    } catch (e) {}
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
