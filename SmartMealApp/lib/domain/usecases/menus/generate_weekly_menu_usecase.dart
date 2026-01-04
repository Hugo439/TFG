import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';

/// Parámetros para la generación de menú semanal con IA.
class GenerateWeeklyMenuParams {
  /// ID del usuario para quien se genera el menú.
  final String userId;

  /// Calorías objetivo diarias (se dividirán entre 4 comidas).
  final int targetCaloriesPerDay;

  /// Lista de alergias/ingredientes a evitar.
  final List<String> allergies;

  /// Objetivo del usuario: 'lose_weight', 'maintain_weight', 'gain_weight', 'gain_muscle'.
  final String userGoal;

  const GenerateWeeklyMenuParams({
    required this.userId,
    required this.targetCaloriesPerDay,
    required this.allergies,
    required this.userGoal,
  });
}

/// Caso de uso para generar un menú semanal usando IA.
///
/// Delega la generación al repositorio que coordina con Gemini API.
///
/// Resultado:
/// - 28 recetas únicas (7 días × 4 comidas)
/// - Distribución calórica realista por tipo de comida
/// - Ingredientes con cantidades y unidades
/// - Pasos de preparación
///
/// El repository se encarga de:
/// - Validación de respuesta de IA
/// - Sanitización de índices
/// - Reintentos en caso de error
/// - Generación de pasos faltantes
///
/// Throws: [ServerFailure] si falla la generación después de reintentos.
class GenerateWeeklyMenuUseCase
    implements UseCase<WeeklyMenu, GenerateWeeklyMenuParams> {
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
