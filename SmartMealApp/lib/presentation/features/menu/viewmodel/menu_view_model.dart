import 'package:flutter/material.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';

/// Estados posibles de la pantalla de menús.
enum MenuState { initial, loading, loaded, error }

/// ViewModel para la pantalla de lista de menús semanales.
///
/// Responsabilidades:
/// - Cargar menús guardados del usuario
/// - Gestionar estados de carga/error
/// - Notificar cambios a la UI
///
/// Flujo típico:
/// 1. Usuario abre pantalla de menús
/// 2. loadWeeklyMenus(userId) carga menús desde Firestore
/// 3. Estado cambia: initial → loading → loaded
/// 4. UI muestra lista de menús
///
/// Estados:
/// - **initial**: Estado inicial antes de cargar
/// - **loading**: Cargando menús desde Firestore
/// - **loaded**: Menús cargados exitosamente
/// - **error**: Error al cargar menús
///
/// Propiedades:
/// - **menus**: lista de WeeklyMenu del usuario
/// - **errorMessage**: mensaje de error si state == error
///
/// Uso:
/// ```dart
/// final vm = Provider.of<MenuViewModel>(context);
/// await vm.loadWeeklyMenus(userId);
/// if (vm.state == MenuState.loaded) {
///   // Mostrar vm.menus
/// }
/// ```
class MenuViewModel extends ChangeNotifier {
  final WeeklyMenuRepository _weeklyMenuRepository = sl<WeeklyMenuRepository>();

  MenuState _state = MenuState.initial;
  MenuState get state => _state;

  List<WeeklyMenu> _menus = [];
  List<WeeklyMenu> get menus => _menus;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  /// Carga todos los menús semanales del usuario desde Firestore.
  ///
  /// Parámetros:
  /// - **userId**: ID del usuario propietario
  ///
  /// Flujo:
  /// 1. Cambia estado a loading
  /// 2. Llama a WeeklyMenuRepository.getWeeklyMenus()
  /// 3. Si éxito: actualiza _menus y cambia a loaded
  /// 4. Si error: guarda mensaje y cambia a error
  ///
  /// Emite notifyListeners() en cada cambio de estado.
  Future<void> loadWeeklyMenus(String userId) async {
    _state = MenuState.loading;
    safeNotifyListeners();
    try {
      final result = await _weeklyMenuRepository.getWeeklyMenus(userId);
      _menus = result;
      _state = MenuState.loaded;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = MenuState.error;
      safeNotifyListeners();
    }
  }
}
