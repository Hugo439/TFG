/// Clase base abstracta para representar errores de dominio en la aplicación.
///
/// Los [Failure] son objetos inmutables que encapsulan información sobre errores
/// que ocurren en la capa de dominio. A diferencia de las excepciones, estos
/// se retornan como valores y permiten un manejo de errores más funcional.
///
/// Cada tipo específico de [Failure] representa una categoría de error distinta,
/// permitiendo al código cliente manejarlos de forma diferenciada.
abstract class Failure {
  /// Mensaje descriptivo del error para mostrar al usuario.
  final String message;

  /// Crea un [Failure] con un [message] descriptivo.
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Error relacionado con problemas de conectividad de red.
///
/// Se usa cuando no hay conexión a internet o hay timeout en peticiones.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de conexión']);
}

/// Error relacionado con respuestas incorrectas del servidor.
///
/// Se usa cuando el servidor responde con códigos 5xx o datos mal formados.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Error al acceder o guardar datos en la caché local.
///
/// Se usa cuando falla lectura/escritura en almacenamiento local.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché']);
}

/// Error relacionado con permisos insuficientes.
///
/// Se usa cuando el usuario no tiene los permisos necesarios para una acción.
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permisos insuficientes']);
}

/// Error de autenticación o sesión expirada.
///
/// Se usa cuando las credenciales son inválidas o el token ha expirado.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

/// Error cuando un recurso solicitado no existe.
///
/// Se usa cuando se busca un documento en Firestore que no existe.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Datos no encontrados']);
}

/// Error de validación de datos de entrada.
///
/// Se usa cuando los datos proporcionados no cumplen las reglas de negocio.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

/// Error específico cuando se intenta generar un menú que ya existe.
///
/// Se usa para evitar duplicar ingredientes en la lista de compras.
class MenuAlreadyGeneratedFailure extends Failure {
  const MenuAlreadyGeneratedFailure([
    super.message =
        'Los ingredientes de este menú ya se habían añadido a la lista de compra',
  ]);
}

/// Error genérico para fallos no categorizados.
///
/// Se usa como fallback cuando el tipo de error no encaja en otras categorías.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido']);
}
