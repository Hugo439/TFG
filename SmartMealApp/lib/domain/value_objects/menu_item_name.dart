import 'package:smartmeal/domain/value_objects/value_object.dart';

class MenuItemName extends ValueObject<String> {
  MenuItemName(String value) : super(_validate(value));

  static String _validate(String value) {
    final trimmed = value.trim();
    
    if (trimmed.isEmpty) {
      throw ArgumentError('El nombre del plato no puede estar vacío');
    }
    
    if (trimmed.length < 3) {
      throw ArgumentError('El nombre debe tener al menos 3 caracteres');
    }
    
    if (trimmed.length > 100) {
      throw ArgumentError('El nombre no puede exceder 100 caracteres');
    }
    
    return trimmed;
  }
}