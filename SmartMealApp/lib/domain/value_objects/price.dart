import 'package:smartmeal/domain/value_objects/value_object.dart';

class Price extends ValueObject<double> {
  Price(double value) : super(_validate(value));

  static double _validate(double value) {
    if (value < 0) {
      throw ArgumentError('El precio no puede ser negativo');
    }

    if (value > 10000) {
      throw ArgumentError('El precio no puede exceder €10,000');
    }

    return value;
  }

  factory Price.fromString(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      throw ArgumentError('El precio debe ser un número válido');
    }
    return Price(parsed);
  }

  String get formatted => '€${value.toStringAsFixed(2)}';

  static Price? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return Price.fromString(value);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => '€${value.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Price &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
