import 'package:smartmeal/core/errors/errors.dart';

/// Utilidad para manejar errores de forma uniforme en toda la aplicación.
///
/// Esta clase proporciona métodos estáticos para:
/// - Envolver operaciones asíncronas y convertir excepciones en [Failure]
/// - Validar condiciones comunes (autenticación, nulidad)
/// - Obtener mensajes amigables para mostrar al usuario
///
/// El enfoque de errores tipados facilita el manejo de fallos específicos
/// y mejora la experiencia del usuario con mensajes contextuales.
class ErrorHandler {
  /// Ejecuta una operación asíncrona y maneja sus excepciones.
  ///
  /// Este método envuelve operaciones que pueden fallar, capturando excepciones
  /// y convirtiéndolas en objetos [Failure] tipados. Los [Failure] conocidos
  /// se relanzan tal cual, mientras que excepciones inesperadas se convierten
  /// en [ServerFailure].
  ///
  /// **Parámetros:**
  /// - [operation]: La función asíncrona a ejecutar que puede fallar
  /// - [errorMapper]: Función opcional para mapear excepciones específicas
  ///   a tipos de [Failure] personalizados
  ///
  /// **Ejemplo:**
  /// ```dart
  /// await ErrorHandler.wrap(
  ///   () => repository.fetchData(),
  ///   errorMapper: (e) => e is TimeoutException
  ///     ? NetworkFailure('Tiempo de espera agotado')
  ///     : null,
  /// );
  /// ```
  static Future<T> wrap<T>(
    Future<T> Function() operation, {
    Failure Function(dynamic)? errorMapper,
  }) async {
    try {
      return await operation();
    } on AuthFailure {
      rethrow;
    } on NotFoundFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } on NetworkFailure {
      rethrow;
    } on ValidationFailure {
      rethrow;
    } on MenuAlreadyGeneratedFailure {
      rethrow;
    } on Failure {
      rethrow;
    } catch (e) {
      if (errorMapper != null) {
        throw errorMapper(e);
      }
      throw ServerFailure('Error inesperado: $e');
    }
  }

  /// Verifica que un usuario esté autenticado.
  ///
  /// Lanza [AuthFailure] si el [user] es null, útil para validar
  /// el estado de autenticación antes de operaciones que lo requieren.
  ///
  /// **Parámetros:**
  /// - [user]: El objeto de usuario a validar (típicamente de Firebase Auth)
  /// - [message]: Mensaje de error personalizado (opcional)
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final user = FirebaseAuth.instance.currentUser;
  /// ErrorHandler.checkAuth(user, message: 'Debes iniciar sesión');
  /// ```
  static void checkAuth(dynamic user, {String? message}) {
    if (user == null) {
      throw AuthFailure(message ?? 'Usuario no autenticado');
    }
  }

  /// Valida que un valor no sea nulo y lo retorna tipado.
  ///
  /// Lanza [NotFoundFailure] si el [value] es null. Útil para asegurar
  /// que datos esperados existen antes de usarlos.
  ///
  /// **Parámetros:**
  /// - [value]: El valor a validar
  /// - [fieldName]: Nombre del campo para el mensaje de error
  ///
  /// **Retorna:** El [value] tipado como no-nullable
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final recipe = ErrorHandler.checkNotNull(
  ///   snapshot.data(),
  ///   'Receta'
  /// );
  /// ```
  static T checkNotNull<T>(T? value, String fieldName) {
    if (value == null) {
      throw NotFoundFailure('$fieldName no encontrado');
    }
    return value;
  }

  /// Obtiene un mensaje amigable para el usuario según el tipo de [Failure].
  ///
  /// Convierte errores técnicos en mensajes comprensibles y accionables
  /// para mostrar en la interfaz de usuario.
  ///
  /// **Parámetro:**
  /// - [failure]: El objeto [Failure] del que obtener el mensaje
  ///
  /// **Retorna:** Un mensaje string amigable para el usuario
  ///
  /// **Ejemplo:**
  /// ```dart
  /// try {
  ///   // operación...
  /// } on Failure catch (e) {
  ///   showSnackbar(ErrorHandler.getUserMessage(e));
  /// }
  /// ```
  static String getUserMessage(Failure failure) {
    return switch (failure) {
      AuthFailure() => 'Sesión expirada. Por favor, inicia sesión de nuevo.',
      ServerFailure() => 'Error del servidor. Por favor, intenta más tarde.',
      NetworkFailure() => 'Sin conexión. Verifica tu conexión a internet.',
      NotFoundFailure() => 'Datos no encontrados.',
      ValidationFailure(:var message) => 'Datos inválidos. $message',
      MenuAlreadyGeneratedFailure(:var message) => message,
      _ => 'Ha ocurrido un error inesperado.',
    };
  }
}
