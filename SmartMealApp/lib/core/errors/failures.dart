/// Clase base para errores de dominio
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Error de conexión/red
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de conexión']);
}

/// Error del servidor
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Error de caché
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché']);
}

/// Error de permisos/autenticación
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permisos insuficientes']);
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

/// Error de datos no encontrados
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Datos no encontrados']);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

/// Error de menú ya generado
class MenuAlreadyGeneratedFailure extends Failure {
  const MenuAlreadyGeneratedFailure([
    super.message = 'Los ingredientes de este menú ya se habían añadido a la lista de compra'
  ]);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido']);
}
