import 'package:smartmeal/domain/value_objects/value_object.dart';

class MenuItemDescription extends ValueObject<String> {
  MenuItemDescription(String value) : super(_validate(value));

  static String _validate(String value) {
    final trimmed = value.trim();
    
    if (trimmed.isEmpty) {
      throw ArgumentError('La descripción no puede estar vacía');
    }
    
    if (trimmed.length > 500) {
      throw ArgumentError('La descripción no puede exceder 500 caracteres');
    }
    
    return trimmed;
  }
  
  static MenuItemDescription? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return MenuItemDescription(value);
    } catch (_) {
      return null;
    }
  }
}