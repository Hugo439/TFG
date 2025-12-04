import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/auth/sign_in_usecase.dart';
import 'package:smartmeal/data/datasources/local/auth_local_datasource.dart';

enum LoginErrorCode {
  fieldsRequired,
  userNotFound,
  wrongPassword,
  invalidEmail,
  userDisabled,
  invalidCredential,
  generic,
}

class LoginViewModel extends ChangeNotifier {
  final SignInUseCase _signIn;
  final AuthLocalDataSource _localDataSource;

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
      _errorCode = LoginErrorCode.fieldsRequired;
      notifyListeners();
      return false;
    }

    _loading = true;
    _errorCode = null;
    notifyListeners();

    try {
      await _signIn(SignInParams(
        email: email,
        password: password,
      ));

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