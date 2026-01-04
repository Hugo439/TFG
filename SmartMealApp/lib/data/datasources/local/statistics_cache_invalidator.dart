import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/data/datasources/local/statistics_local_datasource.dart';

/// Utilidad para invalidar caché de estadísticas.
///
/// Responsabilidad:
/// - Proporcionar método estático para limpiar caché
/// - Se usa cuando menú es modificado
///
/// Cuándo invalidar:
/// 1. Usuario genera nuevo menú
/// 2. Usuario modifica recetas del menú
/// 3. Usuario elimina menú
///
/// Efecto:
/// - Próxima vez que abra estadísticas, recalculará
/// - Asegura datos siempre actualizados
///
/// Uso:
/// ```dart
/// // En GenerateMenuViewModel.saveGeneratedMenu()
/// await _statisticsRepository.clearStatisticsCache(userId);
///
/// // O directamente:
/// await StatisticsCacheInvalidator.clearLocalStatisticsCache();
/// ```
class StatisticsCacheInvalidator {
  /// Limpia caché local de estadísticas.
  ///
  /// Crea instancia de SharedPreferences y StatisticsLocalDatasource
  /// para limpiar caché.
  ///
  /// Método estático para fácil acceso desde cualquier lugar.
  static Future<void> clearLocalStatisticsCache() async {
    final prefs = await SharedPreferences.getInstance();
    final statsLocalDS = StatisticsLocalDatasource(prefs);
    await statsLocalDS.clear();
  }
}
