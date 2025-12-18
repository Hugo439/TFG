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

/// Error de permisos
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permisos insuficientes']);
}

/// Error de datos no encontrados
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Datos no encontrados']);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido']);
}
