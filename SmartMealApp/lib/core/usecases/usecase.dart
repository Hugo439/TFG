/// Interfaz base para todos los casos de uso de la aplicación.
///
/// Los casos de uso encapsulan la lógica de negocio y coordinan el flujo
/// de datos entre la capa de presentación y la capa de datos/dominio.
/// Siguen el principio de responsabilidad única.
///
/// **Tipo genéricos:**
/// - [T]: El tipo de dato que retorna el caso de uso
/// - [Params]: El tipo de parámetros que recibe (usa [NoParams] si no necesita ninguno)
///
/// **Ejemplo de implementación:**
/// ```dart
/// class GetWeeklyMenu extends UseCase<WeeklyMenu, String> {
///   final WeeklyMenuRepository repository;
///
///   GetWeeklyMenu(this.repository);
///
///   @override
///   Future<WeeklyMenu> call(String userId) async {
///     return await repository.getLatestMenu(userId);
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  /// Ejecuta el caso de uso con los [params] especificados.
  ///
  /// Este método debe ser implementado por cada caso de uso concreto
  /// con su lógica específica de negocio.
  Future<T> call(Params params);
}

/// Clase marcadora para casos de uso que no requieren parámetros.
///
/// Usar esta clase cuando un caso de uso no necesita recibir datos de entrada.
///
/// **Ejemplo:**
/// ```dart
/// class GetCurrentUser extends UseCase<User, NoParams> {
///   @override
///   Future<User> call(NoParams params) async {
///     // lógica sin parámetros
///   }
/// }
///
/// // Uso:
/// final user = await getCurrentUser(NoParams());
/// ```
class NoParams {
  const NoParams();
}
