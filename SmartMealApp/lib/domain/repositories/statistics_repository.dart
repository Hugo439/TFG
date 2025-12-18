import 'package:smartmeal/domain/value_objects/statistics_models.dart';

abstract class StatisticsRepository {
  Future<StatisticsSummary> getStatisticsSummary(String userId);
  Future<void> cacheStatisticsSummary(
    String userId,
    StatisticsSummary summary,
    DateTime menuDate,
  );
  Future<void> clearStatisticsCache(
    String userId,
  ); // Invalida caché local y remoto
}
