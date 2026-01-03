import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/statistics/get_statistics_summary_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_current_user_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/value_objects/statistics_models.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/utils/calorie_calculator_utils.dart';
import 'package:smartmeal/core/errors/errors.dart';

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

  Future<void> load() async {
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
