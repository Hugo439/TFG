import 'package:smartmeal/domain/repositories/app_repository.dart';

/// Implementación del repositorio de inicialización de la app.
///
/// Responsabilidad:
/// - Placeholder para inicializaciones futuras
///
/// Nota:
/// - Firebase se inicializa en service_locator.dart
/// - Este repositorio está vacío actualmente
/// - Se mantiene para extensibilidad futura
///
/// Posibles usos futuros:
/// - Inicializar bases de datos locales
/// - Configurar servicios de terceros
/// - Cargar configuración remota
/// - Migrar datos de versiones antiguas
class AppRepositoryImpl implements AppRepository {
  @override
  Future<void> initialize() async {
    // Firebase ya se inicializa en service_locator.dart
    // Este método ahora está vacío pero se mantiene por si se necesita
    // inicializar otras dependencias en el futuro
  }
}
