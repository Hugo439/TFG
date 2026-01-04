import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'presentation/app/smart_meal_app.dart';
import 'core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'domain/usecases/support/get_support_messages_usecase.dart';
import 'domain/repositories/support_message_repository.dart';
import 'core/services/fcm_service.dart';
import 'presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/core/services/firestore_init_service.dart';
import 'presentation/routes/routes.dart';
import 'dart:async' show unawaited;

/// Punto de entrada principal de la aplicación SmartMeal.
///
/// Secuencia de inicialización:
/// 1. **WidgetsFlutterBinding**: inicializa Flutter framework
/// 2. **Firebase**: Firebase.initializeApp() con opciones de plataforma
/// 3. **Service Locator**: setupServiceLocator() registra dependencias
/// 4. **Price Database**: FirestoreInitService inicializa catálogo de precios
/// 5. **FCM Permissions**: solicita permisos de notificaciones push
/// 6. **Auth Listener**: escucha cambios de autenticación
/// 7. **MultiProvider**: configura providers globales
/// 8. **runApp**: lanza SmartMealApp
/// 9. **Post-frame**: configura handlers de notificaciones
///
/// navigatorKey:
/// - GlobalKey<NavigatorState> global
/// - Permite navegación desde fuera del BuildContext
/// - Usado por FCM para navegar al recibir notificaciones
///
/// subirCatalogoPreciosRespetandoCampos():
/// - Comentado por defecto
/// - Usar para actualizar catálogo de precios en Firestore
/// - Solo ejecutar cuando se necesite actualizar precios
///
/// Auth State Listener:
/// - Escucha authStateChanges() de FirebaseAuth
/// - Cuando user != null:
///   * Inicializa FCM (tokens, handlers)
///   * Carga menús automáticamente
/// - Garantiza datos listos al autenticarse
///
/// Providers globales:
/// - StreamProvider<User?>: estado de autenticación
/// - GetSupportMessagesUseCase: lógica de soporte
/// - SupportMessageRepository: acceso a mensajes
///
/// FCM Notification Handlers:
/// - setupNotificationHandlers en post-frame callback
/// - Future.delayed(100ms) para asegurar navegación estable
/// - type='support': navega a SupportView
/// - Extensible para otros tipos de notificaciones
///
/// Errores comunes:
/// - Si Firebase no inicializa: verificar firebase_options.dart
/// - Si Service Locator falla: revisar configuración de DI
/// - Si FCM no funciona: verificar permisos en AndroidManifest/Info.plist
///
/// Orden de ejecución:
/// - Síncrono hasta setupServiceLocator()
/// - Inicialización de price database en background (unawaited)
/// - AuthState listener se activa cuando hay autenticación
/// - Post-frame callback se ejecuta después del primer frame
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupServiceLocator();

  unawaited(FirestoreInitService.initializePriceDatabase());

  await FirebaseMessaging.instance.requestPermission();

  // await subirCatalogoPreciosRespetandoCampos();// Actualizar catálogo de precios, descomentar cuando quieras actualizarlo

  // Inicializar FCM y cargar menús cuando hay un usuario autenticado
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      sl<FCMService>().initialize();
      // Cargar menús automáticamente al autenticarse
      sl<MenuViewModel>().loadWeeklyMenus(user.uid);
    }
  });

  runApp(
    MultiProvider(
      providers: [
        // Providers globales
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        Provider<GetSupportMessagesUseCase>(
          create: (_) => sl<GetSupportMessagesUseCase>(),
        ),
        Provider<SupportMessageRepository>(
          create: (_) => sl<SupportMessageRepository>(),
        ),
      ],
      child: SmartMealApp(navigatorKey: navigatorKey),
    ),
  );

  // Configurar handlers de notificaciones después de que la app esté construida
  WidgetsBinding.instance.addPostFrameCallback((_) {
    sl<FCMService>().setupNotificationHandlers((String? type) {
      if (type == 'support') {
        // Usar Future.delayed para asegurar que la navegación ocurra después del frame
        Future.delayed(const Duration(milliseconds: 100), () {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushNamed(Routes.support);
          }
        });
      }
    });
  });
}
