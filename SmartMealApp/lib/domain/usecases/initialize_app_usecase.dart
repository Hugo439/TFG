import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/app_repository.dart';

/// UseCase para inicializar la aplicación.
///
/// Responsabilidad:
/// - Inicializar servicios de Firebase
/// - Configurar listeners de estado de auth
/// - Inicializar base de datos de precios
/// - Cargar configuración inicial
///
/// Entrada:
/// - NoParams
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// En main.dart o splash screen
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///    Inicializar app
///   await initializeAppUseCase(NoParams());
///
///   runApp(MyApp());
/// }
/// ```
///
/// Tareas de inicialización:
/// 1. Firebase Core
/// 2. Firebase Auth
/// 3. Firestore
/// 4. Firebase Storage
/// 5. Cloud Messaging (notificaciones)
/// 6. Base de datos de precios
/// 7. Listeners de auth state
///
/// Nota: Esta operación debe completarse antes de usar la app.
class InitializeAppUseCase implements UseCase<void, NoParams> {
  final AppRepository repository;

  InitializeAppUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.initialize();
  }
}
