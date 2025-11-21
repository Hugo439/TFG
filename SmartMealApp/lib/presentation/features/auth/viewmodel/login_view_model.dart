import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/sign_in_usecase.dart';
import 'package:smartmeal/data/datasources/local/auth_local_datasource.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInUseCase _signIn;
  final AuthLocalDataSource _localDataSource;

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _loading = false;
  String? _error;

  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _loading;
  String? get error => _error;

  LoginViewModel(this._signIn, this._localDataSource) {
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await _localDataSource.getSavedCredentials();
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

  Future<bool> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _error = 'Por favor completa todos los campos';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _signIn(SignInParams(
        email: email,
        password: password,
      ));

      // Guardar o limpiar credenciales según "Recordarme"
      if (_rememberMe) {
        await _localDataSource.saveCredentials(email, password);
      } else {
        await _localDataSource.clearCredentials();
      }

      _email = email;
      _password = password;
      _loading = false;
      notifyListeners();
      return true;
    } on ArgumentError catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _getErrorMessage(e.toString());
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No existe una cuenta con este correo';
    } else if (error.contains('wrong-password')) {
      return 'Contraseña incorrecta';
    } else if (error.contains('invalid-email')) {
      return 'Correo electrónico inválido';
    } else if (error.contains('user-disabled')) {
      return 'Esta cuenta ha sido deshabilitada';
    } else if (error.contains('invalid-credential')) {
      return 'Credenciales inválidas';
    }
    return 'Error al iniciar sesión';
  }
}