import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/data/datasources/local/statistics_local_datasource.dart';

class StatisticsCacheInvalidator {
  static Future<void> clearLocalStatisticsCache() async {
    final prefs = await SharedPreferences.getInstance();
    final statsLocalDS = StatisticsLocalDatasource(prefs);
    await statsLocalDS.clear();
  }
}
