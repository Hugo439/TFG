import 'package:smartmeal/domain/value_objects/value_object.dart';

/// Value Object que representa y valida una dirección de correo electrónico.
///
/// Garantiza que todos los emails en el sistema cumplan con:
/// - Formato válido según RFC 5322 (simplificado)
/// - No estar vacíos
/// - Normalización (lowercase, trim)
///
/// **Validaciones:**
/// - Presencia de @
/// - Parte local antes del @
/// - Dominio después del @
/// - Extensión de dominio válida (.com, .es, etc)
///
/// **Ejemplo:**
/// ```dart
/// final email = Email('usuario@ejemplo.com');
/// print(email.value); // 'usuario@ejemplo.com'
///
/// final invalid = Email('invalid'); // Lanza ArgumentError
/// ```
class Email extends ValueObject<String> {
  /// Crea un [Email] validando el formato.
  ///
  /// **Lanza:** [ArgumentError] si el email es inválido.
  Email(String value) : super(_validate(value));

  /// Valida y normaliza el email.
  ///
  /// - Elimina espacios en blanco
  /// - Convierte a minúsculas
  /// - Verifica formato con expresión regular
  static String _validate(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('El correo electrónico no puede estar vacío');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      throw ArgumentError('Formato de correo electrónico inválido');
    }

    return trimmed.toLowerCase();
  }

  /// Intenta crear un Email sin lanzar excepciones.
  ///
  /// **Retorna:** [Email] si es válido, `null` si no lo es.
  ///
  /// Útil para validación en formularios sin try-catch.
  static Email? tryParse(String? value) {
    if (value == null) return null;
    try {
      return Email(value);
    } catch (_) {
      return null;
    }
  }
}
