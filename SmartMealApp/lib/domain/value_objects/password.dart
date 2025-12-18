import 'package:smartmeal/domain/value_objects/value_object.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

class Password extends ValueObject<String> {
  Password(String value) : super(_validate(value));

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

  bool get isStrong {
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialChars;
  }
}
