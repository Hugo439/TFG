import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';

class GetWeeklyMenusUseCase implements UseCase<List<WeeklyMenu>, String> {
  final WeeklyMenuRepository _repository;

  GetWeeklyMenusUseCase(this._repository);

  @override
  Future<List<WeeklyMenu>> call(String userId) {
    return _repository.getUserMenus(userId);
  }
}