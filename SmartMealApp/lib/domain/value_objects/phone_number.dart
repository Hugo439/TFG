import 'package:smartmeal/domain/value_objects/value_object.dart';

class PhoneNumber extends ValueObject<String> {
  PhoneNumber(String value) : super(_validate(value));

  static String _validate(String value) {
    final trimmed = value.trim();
    
    if (trimmed.isEmpty) {
      throw ArgumentError('El teléfono no puede estar vacío');
    }
    
    // Remover espacios, guiones y paréntesis
    final cleaned = trimmed.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Validar que contenga solo dígitos y opcionalmente + al inicio
    if (!RegExp(r'^\+?\d{9,15}$').hasMatch(cleaned)) {
      throw ArgumentError('Formato de teléfono inválido');
    }
    
    return cleaned;
  }
  
  static PhoneNumber? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return PhoneNumber(value);
    } catch (_) {
      return null;
    }
  }
  
  String get formatted {
    // Formato español: +34 XXX XX XX XX
    if (value.startsWith('+34') && value.length == 12) {
      return '+34 ${value.substring(3, 6)} ${value.substring(6, 8)} ${value.substring(8, 10)} ${value.substring(10)}';
    }
    return value;
  }
}