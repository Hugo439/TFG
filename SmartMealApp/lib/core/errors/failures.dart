/// Clase base para errores de dominio
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Error de conexión/red
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Error de conexión'])
      : super(message);
}

/// Error del servidor
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor'])
      : super(message);
}

/// Error de caché
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de caché'])
      : super(message);
}

/// Error de permisos
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permisos insuficientes'])
      : super(message);
}

/// Error de datos no encontrados
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Datos no encontrados'])
      : super(message);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Error de validación'])
      : super(message);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Error desconocido'])
      : super(message);
}
