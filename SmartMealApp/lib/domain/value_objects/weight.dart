import 'package:smartmeal/domain/value_objects/value_object.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Value Object que representa el peso corporal de un usuario.
///
/// Valida que el peso esté dentro de rangos fisiológicamente válidos
/// y proporciona utilidades de formateo y cálculo.
///
/// **Validaciones:**
/// - Mínimo: 20 kg (configurable en AppConstants)
/// - Máximo: 500 kg (configurable en AppConstants)
///
/// **Funcionalidades adicionales:**
/// - Formateo con unidad ("75.5 kg")
/// - Cálculo de IMC en combinación con altura
/// - Parsing desde string
///
/// **Ejemplo:**
/// ```dart
/// final weight = Weight(75.5);
/// print(weight.formatted); // "75.5 kg"
///
/// final height = Height(175);
/// final bmi = weight.calculateBMI(height); // 24.65
/// ```
class Weight extends ValueObject<double> {
  /// Crea un [Weight] validando el rango.
  ///
  /// **Lanza:** [ArgumentError] si el peso está fuera de rango.
  Weight(double value) : super(_validate(value));

  /// Valida que el peso esté en rango aceptable.
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

  /// Crea un [Weight] desde un string numérico.
  ///
  /// **Lanza:** [ArgumentError] si el string no es un número válido.
  factory Weight.fromString(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      throw ArgumentError('El peso debe ser un número válido');
    }
    return Weight(parsed);
  }

  /// Obtiene el peso formateado con una decimal y unidad.
  ///
  /// **Ejemplo:** 75.5 -> "75.5 kg"
  String get formatted => '${value.toStringAsFixed(1)} kg';

  /// Calcula el Índice de Masa Corporal (IMC) usando la altura.
  ///
  /// **Fórmula:** IMC = peso(kg) / altura(m)²
  ///
  /// **Parámetro:**
  /// - [height]: La altura del usuario
  ///
  /// **Retorna:** El IMC calculado
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final weight = Weight(70);
  /// final height = Height(175);
  /// final bmi = weight.calculateBMI(height); // 22.86
  /// ```
  double calculateBMI(Height height) {
    return value / (height.meters * height.meters);
  }
}
