import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/usecases/generate_weekly_menu_usecase.dart';
import 'package:smartmeal/domain/usecases/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/get_current_user_usecase.dart';
import 'package:smartmeal/domain/usecases/save_menu_recipes_usecase.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';

enum GenerateMenuStatus { idle, loading, success, error }

class GenerateMenuState {
  final GenerateMenuStatus status;
  final WeeklyMenu? generatedMenu;
  final String? error;

  const GenerateMenuState({
    this.status = GenerateMenuStatus.idle,
    this.generatedMenu,
    this.error,
  });

  GenerateMenuState copyWith({
    GenerateMenuStatus? status,
    WeeklyMenu? generatedMenu,
    String? error,
  }) {
    return GenerateMenuState(
      status: status ?? this.status,
      generatedMenu: generatedMenu ?? this.generatedMenu,
      error: error,
    );
  }
}

class GenerateMenuViewModel extends ChangeNotifier {
  final GenerateWeeklyMenuUseCase _generateWeeklyMenu;
  final GetUserProfileUseCase _getUserProfile;
  final GetCurrentUserUseCase _getCurrentUser;
  final WeeklyMenuRepository _weeklyMenuRepository;
  final SaveMenuRecipesUseCase _saveMenuRecipesUseCase;

  GenerateMenuState _state = const GenerateMenuState();
  GenerateMenuState get state => _state;

  GenerateMenuViewModel(
    this._generateWeeklyMenu,
    this._getUserProfile,
    this._getCurrentUser,
    this._weeklyMenuRepository,
    this._saveMenuRecipesUseCase,
  );

  Future<void> generateMenu() async {
    _state = _state.copyWith(
      status: GenerateMenuStatus.loading,
      error: null,
    );
    notifyListeners();

    try {
      // Obtener usuario actual
      final currentUser = await _getCurrentUser(const NoParams());
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener perfil del usuario
      final profile = await _getUserProfile(const NoParams());

      // Calcular calorías según el objetivo del usuario
      final targetCalories = _calculateCaloriesFromGoal(profile.goal.displayName);

      // Obtener alergias del perfil
      final allergies = profile.allergies?.value.split(',').map((e) => e.trim()).toList() ?? [];

      // Calcular inicio de la semana actual
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      // Generar menú
      final params = GenerateWeeklyMenuParams(
        userId: currentUser.uid,
        userProfile: profile,
        startDate: weekStart,
        targetCaloriesPerDay: targetCalories,
        excludedTags: allergies,
      );

      final menu = await _generateWeeklyMenu(params);

      _state = _state.copyWith(
        status: GenerateMenuStatus.success,
        generatedMenu: menu,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        status: GenerateMenuStatus.error,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> saveGeneratedMenu() async {
    if (_state.generatedMenu == null) {
      throw Exception('No hay menú para guardar');
    }

    await _weeklyMenuRepository.saveMenu(_state.generatedMenu!);
  }

  Future<void> generateMenuAndSaveRecipes(WeeklyMenu menu) async {
    await _saveMenuRecipesUseCase(menu);
    await _weeklyMenuRepository.saveMenu(menu);
    // ...actualiza estado y notifica...
  }

  int _calculateCaloriesFromGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'perder peso':
      case 'pérdida de peso':
        return 1800; // Déficit calórico
      case 'mantener peso':
      case 'mantenimiento':
        return 2200; // Mantenimiento
      case 'ganar peso':
      case 'ganancia muscular':
      case 'ganar músculo':
        return 2800; // Superávit calórico
      default:
        return 2000; // Por defecto
    }
  }
}