import 'package:smartmeal/domain/value_objects/value_object.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

class Height extends ValueObject<int> {
  Height(int value) : super(_validate(value));

  static int _validate(int value) {
    if (value < AppConstants.minHeightCm) {
      throw ArgumentError(
        'La altura debe ser mayor o igual a ${AppConstants.minHeightCm} cm',
      );
    }

    if (value > AppConstants.maxHeightCm) {
      throw ArgumentError(
        'La altura debe ser menor o igual a ${AppConstants.maxHeightCm} cm',
      );
    }

    return value;
  }

  factory Height.fromString(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw ArgumentError('La altura debe ser un número válido');
    }
    return Height(parsed);
  }

  String get formatted => '$value cm';

  double get meters => value / 100.0;
}
