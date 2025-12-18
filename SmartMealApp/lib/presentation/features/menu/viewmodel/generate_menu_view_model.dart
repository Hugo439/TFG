import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/utils/calorie_calculator_utils.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_current_user_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/save_menu_recipes_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/generate_weekly_menu_usecase.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/statistics_repository.dart';

enum GenerateMenuStatus { idle, generating, preview, saving, success, error }

class GenerateMenuState {
  final GenerateMenuStatus status;
  final WeeklyMenu? generatedMenu;
  final String? error;
  final double? progress;

  const GenerateMenuState({
    this.status = GenerateMenuStatus.idle,
    this.generatedMenu,
    this.error,
    this.progress,
  });

  GenerateMenuState copyWith({
    GenerateMenuStatus? status,
    WeeklyMenu? generatedMenu,
    String? error,
    double? progress,
  }) {
    return GenerateMenuState(
      status: status ?? this.status,
      generatedMenu: generatedMenu ?? this.generatedMenu,
      error: error,
      progress: progress ?? this.progress,
    );
  }
}

class GenerateMenuViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfile;
  final GetCurrentUserUseCase _getCurrentUser;
  final GenerateWeeklyMenuUseCase _generateWeeklyMenu;
  final WeeklyMenuRepository _weeklyMenuRepository;
  final SaveMenuRecipesUseCase _saveMenuRecipesUseCase;
  final StatisticsRepository _statisticsRepository; // Nueva inyección

  GenerateMenuState _state = const GenerateMenuState();
  GenerateMenuState get state => _state;

  GenerateMenuViewModel(
    this._getUserProfile,
    this._getCurrentUser,
    this._generateWeeklyMenu,
    this._weeklyMenuRepository,
    this._saveMenuRecipesUseCase,
    this._statisticsRepository, // Nuevo parámetro
  );

  /// Genera un nuevo menú semanal y lo muestra en preview
  Future<void> generateMenu() async {
    _state = _state.copyWith(
      status: GenerateMenuStatus.generating,
      error: null,
      progress: 0.0,
    );
    notifyListeners();

    try {
      // Paso 1: Obtener usuario actual
      _updateProgress(0.1);
      final currentUser = await _getCurrentUser(const NoParams());
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      if (kDebugMode) {
        print('📋 [GenerateMenuVM] Usuario: ${currentUser.uid}');
      }

      // Paso 2: Obtener perfil del usuario
      _updateProgress(0.2);
      final profile = await _getUserProfile(const NoParams());

      // Paso 3: Calcular calorías según el objetivo del usuario
      _updateProgress(0.3);
      final targetCalories = _calculateCaloriesFromProfile(profile);

      // Paso 4: Obtener alergias del perfil
      final allergies =
          profile.allergies?.value.split(',').map((e) => e.trim()).toList() ??
          [];

      if (kDebugMode) {
        print('📋 [GenerateMenuVM] Calorías objetivo: $targetCalories');
        print('📋 [GenerateMenuVM] Alergias: $allergies');
        print('📋 [GenerateMenuVM] Objetivo: ${profile.goal.displayName}');
      }

      // Paso 5: Generar menú con Gemini
      _updateProgress(0.4);
      final menu = await _generateWeeklyMenu(
        GenerateWeeklyMenuParams(
          userId: currentUser.uid,
          targetCaloriesPerDay: targetCalories,
          allergies: allergies,
          userGoal: profile.goal.displayName,
        ),
      );

      if (kDebugMode) {
        print('📋 [GenerateMenuVM] Menú generado:');
        print('   - ID: ${menu.id}');
        print('   - UserID: ${menu.userId}');
        print('   - Nombre: ${menu.name}');
        print('   - Total recetas: 28'); //${menu.allRecipes.length}
        print('   - Días: ${menu.days.length}');
        for (var day in menu.days) {
          print('     - ${day.day}: ${day.recipes.length} recetas');
        }
      }

      _updateProgress(1.0);

      // Mostrar preview
      _state = _state.copyWith(
        status: GenerateMenuStatus.preview,
        generatedMenu: menu,
        progress: 1.0,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GenerateMenuVM] Error generando: $e');
      }
      _state = _state.copyWith(
        status: GenerateMenuStatus.error,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Guarda el menú generado (recetas + menú semanal)
  Future<void> saveGeneratedMenu() async {
    if (_state.generatedMenu == null) {
      throw Exception('No hay menú para guardar');
    }

    _state = _state.copyWith(
      status: GenerateMenuStatus.saving,
      error: null,
      progress: 0.0,
    );
    notifyListeners();

    try {
      if (kDebugMode) {
        print('💾 [GenerateMenuVM] Iniciando guardado...');
        print('   - Menú ID: ${_state.generatedMenu!.id}');
        print('   - User ID: ${_state.generatedMenu!.userId}');
      }

      // Paso 1: Guardar todas las recetas primero
      _updateProgress(0.3);
      if (kDebugMode) {
        print(
          '💾 [GenerateMenuVM] Guardando 28 recetas...',
        ); //${_state.generatedMenu!.allRecipes.length}
      }
      await _saveMenuRecipesUseCase(_state.generatedMenu!);

      if (kDebugMode) {
        print('✅ [GenerateMenuVM] Recetas guardadas');
      }

      // Paso 2: Guardar el menú semanal (con referencias a recetas ya guardadas)
      _updateProgress(0.7);
      if (kDebugMode) {
        print('💾 [GenerateMenuVM] Guardando menú semanal...');
      }
      await _weeklyMenuRepository.saveMenu(_state.generatedMenu!);

      // Invalidar caché de estadísticas después de guardar el menú
      await _statisticsRepository.clearStatisticsCache(
        _state.generatedMenu!.userId,
      );

      if (kDebugMode) {
        print('✅ [GenerateMenuVM] Menú semanal guardado');
      }

      _updateProgress(1.0);

      // Éxito
      _state = _state.copyWith(
        status: GenerateMenuStatus.success,
        progress: 1.0,
      );
      notifyListeners();

      if (kDebugMode) {
        print('🎉 [GenerateMenuVM] Guardado completado con éxito');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GenerateMenuVM] Error guardando: $e');
      }
      _state = _state.copyWith(
        status: GenerateMenuStatus.error,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Rechaza el menú generado y vuelve a idle
  void discardMenu() {
    _state = const GenerateMenuState(status: GenerateMenuStatus.idle);
    notifyListeners();
  }

  /// Resetea el estado a idle
  void reset() {
    _state = const GenerateMenuState();
    notifyListeners();
  }

  void _updateProgress(double value) {
    _state = _state.copyWith(progress: value);
    notifyListeners();
  }

  int _calculateCaloriesFromProfile(UserProfile profile) {
    return CalorieCalculator.calculateFromProfile(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      goal: profile.goalValue,
      age: profile.ageValue,
      gender: profile.genderValue,
    );
  }
}
