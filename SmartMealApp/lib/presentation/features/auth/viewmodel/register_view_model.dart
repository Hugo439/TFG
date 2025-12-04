import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/sign_up_usecase.dart';

enum RegisterErrorCode {
  emailInUse,
  invalidEmail,
  weakPassword,
  generic,
}

class RegisterViewModel extends ChangeNotifier {
  final SignUpUseCase _signUp;

  String _goal = 'Perder peso';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  RegisterErrorCode? _errorCode;

  String get goal => _goal;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _loading;
  RegisterErrorCode? get errorCode => _errorCode;

  RegisterViewModel(this._signUp);

  void setGoal(String value) {
    _goal = value;
    _errorCode = null;
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
    int? age,
    String? gender,
  ) async {
    _loading = true;
    _errorCode = null;
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
        age: age,
        gender: gender,
      ));

      _loading = false;
      notifyListeners();
      return true;
    } on ArgumentError {
      _errorCode = RegisterErrorCode.generic;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('email-already-in-use')) {
        _errorCode = RegisterErrorCode.emailInUse;
      } else if (msg.contains('invalid-email')) {
        _errorCode = RegisterErrorCode.invalidEmail;
      } else if (msg.contains('weak-password')) {
        _errorCode = RegisterErrorCode.weakPassword;
      } else {
        _errorCode = RegisterErrorCode.generic;
      }
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}