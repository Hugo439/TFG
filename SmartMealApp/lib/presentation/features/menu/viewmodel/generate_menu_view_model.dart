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
import 'package:smartmeal/core/errors/errors.dart';

/// Estados del proceso de generación de menú.
enum GenerateMenuStatus { idle, generating, preview, saving, success, error }

/// Estado del ViewModel de generación de menú.
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

/// ViewModel para generación de menú semanal con IA.
///
/// Responsabilidades:
/// - Orquestar generación de menú con Gemini/Groq
/// - Gestionar preview del menú generado
/// - Guardar menú y recetas en Firestore
/// - Invalidar caché de estadísticas
///
/// Flujo completo:
/// 1. **Generación** (generateMenu):
///    - Obtiene usuario y perfil
///    - Calcula calorías objetivo según perfil
///    - Llama a GenerateWeeklyMenuUseCase (IA)
///    - Cambia estado a 'preview'
///
/// 2. **Preview**:
///    - Usuario revisa menú generado
///    - Opciones: guardar o descartar
///
/// 3. **Guardado** (saveGeneratedMenu):
///    - Guarda 28 recetas en Firestore
///    - Guarda menú semanal con referencias
///    - Invalida caché de estadísticas
///    - Cambia estado a 'success'
///
/// Estados:
/// - **idle**: Sin menú generado
/// - **generating**: Llamando a IA (0.0-1.0 progress)
/// - **preview**: Menú generado, esperando decisión
/// - **saving**: Guardando en Firestore (0.0-1.0 progress)
/// - **success**: Guardado exitoso
/// - **error**: Error en generación o guardado
///
/// Uso:
/// ```dart
/// final vm = Provider.of<GenerateMenuViewModel>(context);
/// await vm.generateMenu();
/// if (vm.state.status == GenerateMenuStatus.preview) {
///   // Mostrar preview
///   await vm.saveGeneratedMenu();
/// }
/// ```
class GenerateMenuViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfile;
  final GetCurrentUserUseCase _getCurrentUser;
  final GenerateWeeklyMenuUseCase _generateWeeklyMenu;
  final WeeklyMenuRepository _weeklyMenuRepository;
  final SaveMenuRecipesUseCase _saveMenuRecipesUseCase;
  final StatisticsRepository _statisticsRepository; // Nueva inyección

  GenerateMenuState _state = const GenerateMenuState();
  GenerateMenuState get state => _state;

  bool _disposed = false;

  GenerateMenuViewModel(
    this._getUserProfile,
    this._getCurrentUser,
    this._generateWeeklyMenu,
    this._weeklyMenuRepository,
    this._saveMenuRecipesUseCase,
    this._statisticsRepository, // Nuevo parámetro
  );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Genera un nuevo menú semanal con IA (Gemini/Groq).
  ///
  /// Proceso completo:
  /// 1. Obtiene usuario actual (0.1 progress)
  /// 2. Obtiene perfil del usuario (0.2 progress)
  /// 3. Calcula calorías objetivo según perfil (0.3 progress)
  /// 4. Extrae alergias del perfil
  /// 5. Llama a GenerateWeeklyMenuUseCase con parámetros (0.4-1.0 progress)
  /// 6. Cambia estado a 'preview' con menú generado
  ///
  /// El menú generado contiene:
  /// - 28 recetas (4 por día × 7 días)
  /// - Distribución semanal (breakfast, lunch, snack, dinner)
  /// - Calorías balanceadas según objetivo
  /// - Sin ingredientes alérgicos
  ///
  /// Lanza excepciones si:
  /// - Usuario no autenticado
  /// - Perfil no encontrado
  /// - Error en llamada a IA
  Future<void> generateMenu() async {
    _state = _state.copyWith(
      status: GenerateMenuStatus.generating,
      error: null,
      progress: 0.0,
    );
    _safeNotifyListeners();

    try {
      // Paso 1: Obtener usuario actual
      _updateProgress(0.1);
      final currentUser = await _getCurrentUser(const NoParams());
      if (currentUser == null) {
        throw AuthFailure('Usuario no autenticado');
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
      _safeNotifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GenerateMenuVM] Error generando: $e');
      }
      _state = _state.copyWith(
        status: GenerateMenuStatus.error,
        error: e.toString(),
      );
      _safeNotifyListeners();
    }
  }

  /// Guarda el menú generado en Firestore.
  ///
  /// Requiere:
  /// - state.generatedMenu != null
  /// - state.status == preview
  ///
  /// Proceso en 2 pasos:
  /// 1. **Guardar recetas** (0.3 progress):
  ///    - SaveMenuRecipesUseCase guarda 28 recetas
  ///    - Cada receta obtiene ID único
  ///
  /// 2. **Guardar menú** (0.7 progress):
  ///    - WeeklyMenuRepository guarda menú semanal
  ///    - Menú contiene referencias a IDs de recetas
  ///
  /// 3. **Invalidar caché**:
  ///    - StatisticsRepository.clearStatisticsCache()
  ///    - Fuerza recalcular estadísticas
  ///
  /// Cambia estado a 'success' si todo OK.
  ///
  /// Lanza NotFoundFailure si generatedMenu == null.
  Future<void> saveGeneratedMenu() async {
    if (_state.generatedMenu == null) {
      throw NotFoundFailure('No hay menú para guardar');
    }

    _state = _state.copyWith(
      status: GenerateMenuStatus.saving,
      error: null,
      progress: 0.0,
    );
    _safeNotifyListeners();

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
      _safeNotifyListeners();

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
      _safeNotifyListeners();
    }
  }

  /// Descarta el menú generado y vuelve a estado idle.
  ///
  /// Usado cuando usuario rechaza el preview.
  void discardMenu() {
    _state = const GenerateMenuState(status: GenerateMenuStatus.idle);
    _safeNotifyListeners();
  }

  /// Resetea el ViewModel a estado inicial.
  void reset() {
    _state = const GenerateMenuState();
    _safeNotifyListeners();
  }

  /// Actualiza progreso durante generación/guardado.
  ///
  /// Parámetros:
  /// - **value**: 0.0-1.0
  void _updateProgress(double value) {
    _state = _state.copyWith(progress: value);
    _safeNotifyListeners();
  }

  /// Calcula calorías diarias objetivo según perfil del usuario.
  ///
  /// Usa CalorieCalculator con:
  /// - Peso, altura, edad, género
  /// - Objetivo (perder/mantener/ganar peso)
  ///
  /// Retorna: calorías/día (ej: 2000)
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
