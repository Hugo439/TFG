/// Clase base abstracta para todos los Value Objects del dominio.
///
/// Un Value Object es un objeto inmutable que se identifica por su valor,
/// no por su identidad. Encapsula validación y lógica de negocio relacionada
/// con un tipo de dato específico.
///
/// **Características:**
/// - Inmutabilidad (final fields)
/// - Igualdad por valor (no por referencia)
/// - Auto-validación en construcción
/// - Sin identidad propia
///
/// **Ventajas:**
/// - Garantiza datos válidos en todo el sistema
/// - Evita validaciones repetidas
/// - Encapsula lógica de formateo
/// - Mejora la expresividad del código
///
/// **Tipo genérico:**
/// - [T]: El tipo primitivo que envuelve (String, int, double, etc)
///
/// **Ejemplo de implementación:**
/// ```dart
/// class Email extends ValueObject<String> {
///   Email(String value) : super(_validate(value));
///
///   static String _validate(String value) {
///     // validación aquí
///     return value;
///   }
/// }
/// ```
abstract class ValueObject<T> {
  /// El valor primitivo encapsulado.
  final T value;

  /// Crea un Value Object con el [value] especificado.
  ///
  /// Las clases hijas deben validar el valor antes de llamar super().
  const ValueObject(this.value);

  /// Compara dos Value Objects por su valor, no por referencia.
  ///
  /// Dos Value Objects son iguales si tienen el mismo tipo y valor.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueObject<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  /// Genera hash code basado en el valor.
  ///
  /// Permite usar Value Objects en colecciones basadas en hash (Set, Map).
  @override
  int get hashCode => value.hashCode;

  /// Retorna representación string del valor.
  @override
  String toString() => value.toString();
}
