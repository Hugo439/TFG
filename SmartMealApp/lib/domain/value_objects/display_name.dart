import 'package:smartmeal/domain/value_objects/value_object.dart';

class DisplayName extends ValueObject<String> {
  DisplayName(String value) : super(_validate(value));

  static String _validate(String value) {
    final trimmed = value.trim();
    
    if (trimmed.isEmpty) {
      throw ArgumentError('El nombre no puede estar vacío');
    }
    
    if (trimmed.length < 2) {
      throw ArgumentError('El nombre debe tener al menos 2 caracteres');
    }
    
    if (trimmed.length > 50) {
      throw ArgumentError('El nombre no puede exceder 50 caracteres');
    }
    
    return trimmed;
  }
  
  String get firstLetter => value.isNotEmpty ? value[0].toUpperCase() : '';
}