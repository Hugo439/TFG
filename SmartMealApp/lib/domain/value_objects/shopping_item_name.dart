import 'package:smartmeal/domain/value_objects/value_object.dart';

class ShoppingItemName extends ValueObject<String> {
  ShoppingItemName(String value) : super(_validate(value));

  static String _validate(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('El nombre del producto no puede estar vacío');
    }

    if (trimmed.length > 100) {
      throw ArgumentError('El nombre no puede exceder 100 caracteres');
    }

    return trimmed;
  }
}
