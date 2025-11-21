import 'package:smartmeal/domain/value_objects/value_object.dart';

class ShoppingItemQuantity extends ValueObject<String> {
  ShoppingItemQuantity(String value) : super(_validate(value));

  static String _validate(String value) {
    final trimmed = value.trim();
    
    if (trimmed.isEmpty) {
      throw ArgumentError('La cantidad no puede estar vacía');
    }
    
    return trimmed;
  }
}