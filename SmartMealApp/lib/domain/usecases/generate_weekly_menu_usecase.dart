import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';

class GenerateWeeklyMenuParams {
  final String userId;
  final int targetCaloriesPerDay;
  final List<String> allergies;
  final String userGoal;

  const GenerateWeeklyMenuParams({
    required this.userId,
    required this.targetCaloriesPerDay,
    required this.allergies,
    required this.userGoal,
  });
}

class GenerateWeeklyMenuUseCase implements UseCase<WeeklyMenu, GenerateWeeklyMenuParams> {
  final MenuGenerationRepository _repository;

  GenerateWeeklyMenuUseCase(this._repository);

  @override
  Future<WeeklyMenu> call(GenerateWeeklyMenuParams params) async {
    return await _repository.generateWeeklyMenu(
      userId: params.userId,
      targetCaloriesPerDay: params.targetCaloriesPerDay,
      allergies: params.allergies,
      userGoal: params.userGoal,
    );
  }
}