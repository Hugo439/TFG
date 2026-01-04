import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/usecases/initialize_app_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/check_auth_status_usecase.dart';

/// Estados de la pantalla splash.
enum SplashStatus { idle, loading, authenticated, notAuthenticated, error }

/// Estado del ViewModel de splash.
class SplashState {
  final SplashStatus status;
  final String? error;

  const SplashState({this.status = SplashStatus.idle, this.error});

  SplashState copyWith({SplashStatus? status, String? error}) {
    return SplashState(status: status ?? this.status, error: error);
  }
}

/// ViewModel para pantalla splash (inicio de app).
///
/// Responsabilidades:
/// - Inicializar servicios de la app
/// - Verificar estado de autenticación
/// - Redirigir a login o home según estado
///
/// Proceso de inicialización:
/// 1. **InitializeAppUseCase**:
///    - Inicializa Firebase
///    - Inicializa FCM (notificaciones)
///    - Inicializa Service Locator (DI)
///
/// 2. **CheckAuthStatusUseCase**:
///    - Verifica si hay usuario autenticado
///    - Retorna true/false
///
/// 3. **Navegación**:
///    - authenticated → HomeScreen
///    - notAuthenticated → LoginScreen
///    - error → ErrorScreen
///
/// Estados:
/// - **idle**: sin inicializar
/// - **loading**: inicializando
/// - **authenticated**: usuario autenticado (ir a home)
/// - **notAuthenticated**: sin usuario (ir a login)
/// - **error**: error en inicialización
///
/// Uso:
/// ```dart
/// final vm = Provider.of<SplashViewModel>(context);
/// await vm.initialize();
/// if (vm.state.status == SplashStatus.authenticated) {
///   Navigator.pushReplacementNamed(context, '/home');
/// }
/// ```
class SplashViewModel extends ChangeNotifier {
  final InitializeAppUseCase _initializeApp;
  final CheckAuthStatusUseCase _checkAuthStatus;

  SplashState _state = const SplashState();
  SplashState get state => _state;

  SplashViewModel(this._initializeApp, this._checkAuthStatus);

  /// Inicializa la aplicación y verifica autenticación.
  ///
  /// Flujo:
  /// 1. Cambia estado a loading
  /// 2. Llama a InitializeAppUseCase
  /// 3. Espera 1 segundo (mostrar splash)
  /// 4. Verifica autenticación con CheckAuthStatusUseCase
  /// 5. Actualiza estado según resultado
  ///
  /// Lanza error si falla inicialización.
  Future<void> initialize() async {
    _update(_state.copyWith(status: SplashStatus.loading, error: null));

    try {
      await _initializeApp(const NoParams());
      await Future.delayed(const Duration(seconds: 1));

      final isAuthenticated = await _checkAuthStatus(const NoParams());

      _update(
        _state.copyWith(
          status: isAuthenticated
              ? SplashStatus.authenticated
              : SplashStatus.notAuthenticated,
        ),
      );
    } catch (e) {
      _update(_state.copyWith(status: SplashStatus.error, error: e.toString()));
    }
  }

  void _update(SplashState s) {
    _state = s;
    notifyListeners();
  }
}
