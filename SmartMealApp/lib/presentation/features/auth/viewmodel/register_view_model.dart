import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/usecases/auth/sign_up_usecase.dart';

/// Códigos de error en registro.
enum RegisterErrorCode { emailInUse, invalidEmail, weakPassword, generic }

/// ViewModel para pantalla de registro.
///
/// Responsabilidades:
/// - Gestionar formulario de registro
/// - Crear cuenta con Firebase Auth
/// - Crear perfil de usuario en Firestore
/// - Mapear errores de Firebase a códigos localizables
///
/// Datos requeridos:
/// - Email, password (Auth)
/// - DisplayName, altura, peso, objetivo (Perfil)
/// - Opcionales: alergias, edad, género
///
/// Manejo de errores:
/// - email-already-in-use → RegisterErrorCode.emailInUse
/// - invalid-email → RegisterErrorCode.invalidEmail
/// - weak-password → RegisterErrorCode.weakPassword
///
/// Uso:
/// ```dart
/// final vm = Provider.of<RegisterViewModel>(context);
/// final success = await vm.signUp(
///   displayName, email, password,
///   heightCm, weightKg, goal,
///   allergies, age, gender
/// );
/// ```
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

  /// Crea cuenta de usuario con Firebase Auth y perfil en Firestore.
  ///
  /// Parámetros:
  /// - **displayName**: nombre del usuario
  /// - **email**: correo
  /// - **password**: contraseña (mín 6 caracteres)
  /// - **heightCm**: altura en cm
  /// - **weightKg**: peso en kg
  /// - **goal**: objetivo ("Perder peso", "Mantener", "Ganar músculo")
  /// - **allergies**: alergias separadas por comas (opcional)
  /// - **age**: edad (opcional)
  /// - **gender**: género (opcional)
  ///
  /// Flujo:
  /// 1. Llama a SignUpUseCase
  /// 2. UseCase crea usuario en Auth
  /// 3. UseCase crea perfil en Firestore
  ///
  /// Retorna true si éxito, false si error.
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
      await _signUp(
        SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
          heightCm: heightCm,
          weightKg: weightKg,
          goal: goal,
          allergies: allergies,
          age: age,
          gender: gender,
        ),
      );

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
