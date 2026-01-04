import 'package:smartmeal/domain/value_objects/value_object.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Value Object que representa y valida una contraseña.
///
/// Asegura que todas las contraseñas cumplan requisitos mínimos de seguridad.
///
/// **Validaciones básicas:**
/// - No puede estar vacía
/// - Longitud mínima (configurada en AppConstants)
///
/// **Validación de fortaleza (opcional):**
/// - Mayúsculas
/// - Minúsculas
/// - Números
/// - Caracteres especiales
///
/// **Ejemplo:**
/// ```dart
/// final password = Password('MiPassword123!');
/// print(password.isStrong); // true
///
/// final weak = Password('abc'); // OK si cumple longitud mínima
/// print(weak.isStrong); // false
/// ```
class Password extends ValueObject<String> {
  /// Crea una [Password] validando longitud mínima.
  ///
  /// **Lanza:** [ArgumentError] si la contraseña es inválida.
  Password(String value) : super(_validate(value));

  /// Valida que la contraseña cumpla requisitos mínimos.
  static String _validate(String value) {
    if (value.isEmpty) {
      throw ArgumentError('La contraseña no puede estar vacía');
    }

    if (value.length < AppConstants.minPasswordLength) {
      throw ArgumentError(
        'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres',
      );
    }

    return value;
  }

  /// Verifica si la contraseña es fuerte.
  ///
  /// Una contraseña fuerte debe contener:
  /// - Al menos una mayúscula
  /// - Al menos una minúscula
  /// - Al menos un número
  /// - Al menos un carácter especial
  ///
  /// Útil para mostrar indicadores de fortaleza en la UI.
  bool get isStrong {
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialChars;
  }
}
