import 'package:smartmeal/domain/value_objects/value_object.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

class Weight extends ValueObject<double> {
  Weight(double value) : super(_validate(value));

  static double _validate(double value) {
    if (value < AppConstants.minWeightKg) {
      throw ArgumentError(
        'El peso debe ser mayor o igual a ${AppConstants.minWeightKg} kg',
      );
    }
    
    if (value > AppConstants.maxWeightKg) {
      throw ArgumentError(
        'El peso debe ser menor o igual a ${AppConstants.maxWeightKg} kg',
      );
    }
    
    return value;
  }
  
  factory Weight.fromString(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      throw ArgumentError('El peso debe ser un número válido');
    }
    return Weight(parsed);
  }
  
  String get formatted => '${value.toStringAsFixed(1)} kg';
  
  // Calcular IMC (necesita altura)
  double calculateBMI(Height height) {
    return value / (height.meters * height.meters);
  }
}