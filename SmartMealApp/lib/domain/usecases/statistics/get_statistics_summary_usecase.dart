import 'package:smartmeal/domain/repositories/statistics_repository.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/value_objects/statistics_models.dart';

class GetStatisticsSummaryUseCase
    implements UseCase<StatisticsSummary, String> {
  final StatisticsRepository _repository;
  GetStatisticsSummaryUseCase(this._repository);

  @override
  Future<StatisticsSummary> call(String params) =>
      _repository.getStatisticsSummary(params);
}
