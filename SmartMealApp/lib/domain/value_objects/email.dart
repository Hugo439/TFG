import 'package:smartmeal/domain/value_objects/value_object.dart';

class Email extends ValueObject<String> {
  Email(String value) : super(_validate(value));

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
  
  static Email? tryParse(String? value) {
    if (value == null) return null;
    try {
      return Email(value);
    } catch (_) {
      return null;
    }
  }
}