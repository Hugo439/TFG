import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/auth/sign_in_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/load_saved_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/save_credentials_usecase.dart';
import 'package:smartmeal/core/usecases/usecase.dart';

/// Códigos de error en login.
enum LoginErrorCode {
  fieldsRequired,
  userNotFound,
  wrongPassword,
  invalidEmail,
  userDisabled,
  invalidCredential,
  generic,
}

/// ViewModel para pantalla de login.
///
/// Responsabilidades:
/// - Gestionar campos de email/password
/// - Autenticar usuario con Firebase Auth
/// - Guardar/cargar credenciales (si "Recordarme")
/// - Mapear errores de Firebase a códigos localizables
///
/// Funcionalidades:
/// - **signIn()**: autentica con email/password
/// - **toggleRememberMe()**: activa/desactiva guardar credenciales
/// - **togglePasswordVisibility()**: muestra/oculta password
///
/// Carga automática:
/// - En constructor carga credenciales guardadas si existen
/// - Rellena campos email/password automáticamente
///
/// Manejo de errores:
/// - Parsea excepciones de Firebase
/// - Convierte a LoginErrorCode para localización
/// - Errores: user-not-found, wrong-password, invalid-email, etc.
///
/// Uso:
/// ```dart
/// final vm = Provider.of<LoginViewModel>(context);
/// final success = await vm.signIn(email, password);
/// if (!success) {
///   // Mostrar error según vm.errorCode
/// }
/// ```
class LoginViewModel extends ChangeNotifier {
  final SignInUseCase _signIn;
  final LoadSavedCredentialsUseCase _loadCreds;
  final SaveCredentialsUseCase _saveCreds;

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _loading = false;
  LoginErrorCode? _errorCode;

  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _loading;
  LoginErrorCode? get errorCode => _errorCode;

  LoginViewModel(this._signIn, this._loadCreds, this._saveCreds) {
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await _loadCreds(NoParams());
    if (credentials != null) {
      _email = credentials['email'] ?? '';
      _password = credentials['password'] ?? '';
      _rememberMe = true;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  /// Autentica usuario con Firebase Auth.
  ///
  /// Parámetros:
  /// - **email**: correo del usuario
  /// - **password**: contraseña
  ///
  /// Validaciones:
  /// - email y password no vacíos
  ///
  /// Flujo:
  /// 1. Valida campos
  /// 2. Llama a SignInUseCase
  /// 3. Si rememberMe, guarda credenciales con SaveCredentialsUseCase
  /// 4. Si error, mapea a LoginErrorCode
  ///
  /// Errores Firebase mapeados:
  /// - user-not-found → LoginErrorCode.userNotFound
  /// - wrong-password → LoginErrorCode.wrongPassword
  /// - invalid-email → LoginErrorCode.invalidEmail
  /// - user-disabled → LoginErrorCode.userDisabled
  /// - invalid-credential → LoginErrorCode.invalidCredential
  ///
  /// Retorna true si éxito, false si error.
  Future<bool> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _errorCode = LoginErrorCode.fieldsRequired;
      notifyListeners();
      return false;
    }

    _loading = true;
    _errorCode = null;
    notifyListeners();

    try {
      await _signIn(SignInParams(email: email, password: password));
      await _saveCreds(
        SaveCredentialsParams(
          email: email,
          password: password,
          remember: _rememberMe,
        ),
      );

      _email = email;
      _password = password;
      _loading = false;
      notifyListeners();
      return true;
    } on ArgumentError {
      _errorCode = LoginErrorCode.generic;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('user-not-found')) {
        _errorCode = LoginErrorCode.userNotFound;
      } else if (msg.contains('wrong-password')) {
        _errorCode = LoginErrorCode.wrongPassword;
      } else if (msg.contains('invalid-email')) {
        _errorCode = LoginErrorCode.invalidEmail;
      } else if (msg.contains('user-disabled')) {
        _errorCode = LoginErrorCode.userDisabled;
      } else if (msg.contains('invalid-credential')) {
        _errorCode = LoginErrorCode.invalidCredential;
      } else {
        _errorCode = LoginErrorCode.generic;
      }
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
