import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/statistics/get_statistics_summary_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_current_user_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/value_objects/statistics_models.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/utils/calorie_calculator_utils.dart';
import 'package:smartmeal/core/errors/errors.dart';

/// ViewModel para pantalla de estadísticas del menú.
///
/// Responsabilidades:
/// - Cargar estadísticas del menú actual desde caché/calculadas
/// - Calcular calorías objetivo del usuario
/// - Calcular cumplimiento de objetivo (compliance)
///
/// Estadísticas incluidas:
/// - Distribución de comidas (breakfast, lunch, snack, dinner)
/// - Top 10 ingredientes más usados
/// - Top 10 recetas más frecuentes
/// - Calorías totales semanales y promedio diario
/// - Macronutrientes (proteínas, carbohidratos, grasas)
/// - Coste estimado del menú
///
/// Compliance:
/// - **highDeficit**: < 90% del objetivo (⚠️ alerta)
/// - **onTarget**: 90-110% del objetivo (✅ perfecto)
/// - **surplus**: > 110% del objetivo (⚠️ exceso)
///
/// Caché:
/// - Usa StatisticsCacheModel en Firestore
/// - Si caché válido, carga instantánea
/// - Si no, recalcula desde menú y cachea
///
/// Uso:
/// ```dart
/// final vm = Provider.of<StatisticsViewModel>(context);
/// await vm.load();
/// if (!vm.loading && vm.summary != null) {
///   print('Calorías diarias: ${vm.summary!.avgDailyCalories}');
///   print('Cumplimiento: ${vm.complianceStatus}');
/// }
/// ```
class StatisticsViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetStatisticsSummaryUseCase _getStatisticsSummaryUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  StatisticsViewModel(
    this._getCurrentUserUseCase,
    this._getStatisticsSummaryUseCase,
    this._getUserProfileUseCase,
  );

  bool _loading = false;
  String? _error;
  StatisticsSummary? _summary;
  int? _targetCalories;
  double? _compliancePercent;
  String? _complianceStatus;
  bool _hasLoaded = false;

  bool get loading => _loading;
  String? get error => _error;
  StatisticsSummary? get summary => _summary;
  int? get targetCalories => _targetCalories;
  double? get compliancePercent => _compliancePercent;
  String? get complianceStatus => _complianceStatus;
  bool get hasLoaded => _hasLoaded;

  /// Carga estadísticas del menú actual.
  ///
  /// Proceso:
  /// 1. Obtiene usuario actual
  /// 2. Obtiene perfil del usuario
  /// 3. Calcula calorías objetivo con CalorieCalculator
  /// 4. Carga estadísticas con GetStatisticsSummaryUseCase
  /// 5. Calcula compliance (cumplimiento de objetivo)
  ///
  /// GetStatisticsSummaryUseCase:
  /// - Intenta cargar desde caché
  /// - Si no válido, recalcula y cachea
  ///
  /// Parámetro [forceRefresh]:
  /// - true: Recalcula aunque ya haya datos cargados
  /// - false (default): Solo carga si no hay datos (_hasLoaded == false)
  Future<void> load({bool forceRefresh = false}) async {
    // Si ya se cargó y no es refresh forzado, no recargar
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _getCurrentUserUseCase(NoParams());
      final userId = user?.uid ?? '';
      if (userId.isEmpty) {
        throw AuthFailure('Usuario no autenticado');
      }
      final profile = await _getUserProfileUseCase(NoParams());
      final target = CalorieCalculator.calculateFromProfile(
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
        goal: profile.goalValue,
        age: profile.ageValue,
        gender: profile.genderValue,
      );

      _summary = await _getStatisticsSummaryUseCase(userId);
      _targetCalories = target;
      _computeCompliance();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  /// Fuerza un refresh de las estadísticas.
  ///
  /// Útil cuando:
  /// - Se crea un nuevo menú
  /// - Se modifica la lista de compras
  /// - El usuario quiere actualizar manualmente
  ///
  /// A diferencia de load(), este método SIEMPRE recalcula.
  Future<void> refresh() async {
    await load(forceRefresh: true);
  }

  /// Calcula cumplimiento de objetivo calórico.
  ///
  /// Fórmula:
  /// - compliance% = (avgDailyCalories / targetCalories) * 100
  ///
  /// Categorías:
  /// - **highDeficit**: < 90% (comiendo muy poco)
  /// - **onTarget**: 90-110% (cumpliendo objetivo)
  /// - **surplus**: > 110% (comiendo de más)
  void _computeCompliance() {
    if (_summary == null || _targetCalories == null || _targetCalories == 0) {
      _compliancePercent = null;
      _complianceStatus = null;
      return;
    }
    final avg = _summary!.avgDailyCalories;
    final target = _targetCalories!.toDouble();
    final percent = (avg / target) * 100;
    _compliancePercent = percent;

    if (percent < 90) {
      _complianceStatus = 'highDeficit';
    } else if (percent <= 110) {
      _complianceStatus = 'onTarget';
    } else {
      _complianceStatus = 'surplus';
    }
  }
}
