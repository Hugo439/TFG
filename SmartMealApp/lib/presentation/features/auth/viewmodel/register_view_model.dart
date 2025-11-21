import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/sign_up_usecase.dart';

class RegisterViewModel extends ChangeNotifier {
  final SignUpUseCase _signUp;

  String _goal = 'Perder peso';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  String? _error;

  String get goal => _goal;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _loading;
  String? get error => _error;

  RegisterViewModel(this._signUp);

  void setGoal(String value) {
    _goal = value;
    _error = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<bool> signUp(
    String displayName,
    String email,
    String password,
    int heightCm,
    double weightKg,
    String goal,
    String? allergies,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _signUp(SignUpParams(
        email: email,
        password: password,
        displayName: displayName,
        heightCm: heightCm,
        weightKg: weightKg,
        goal: goal,
        allergies: allergies,
      ));

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
    if (error.contains('email-already-in-use')) {
      return 'Este correo ya está registrado';
    } else if (error.contains('invalid-email')) {
      return 'Correo electrónico inválido';
    } else if (error.contains('weak-password')) {
      return 'La contraseña es muy débil';
    }
    return 'Error al registrarse';
  }
}