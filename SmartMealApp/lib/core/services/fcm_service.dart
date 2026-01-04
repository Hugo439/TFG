import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';

/// Servicio para gestionar Firebase Cloud Messaging (FCM) y notificaciones push.
///
/// Responsabilidades:
/// - Solicitud de permisos de notificaciones
/// - Obtención y gestión de tokens FCM
/// - Almacenamiento de tokens en Firestore
/// - Habilitación/deshabilitación de notificaciones
/// - Manejo de taps en notificaciones
/// - Navegación basada en tipo de notificación
///
/// Ciclo de vida del token FCM:
/// 1. initialize() solicita permisos y obtiene token
/// 2. Token se guarda en Firestore: users/{uid}/fcm_tokens/{token}
/// 3. onTokenRefresh escucha cambios de token
/// 4. disableNotifications() elimina token de Firestore
///
/// Tipos de notificaciones:
/// - **support**: navega a SupportView
/// - **menu**: navega a MenuView (futuro)
/// - **shopping**: navega a ShoppingView (futuro)
/// - Extensible para más tipos
///
/// Estados de notificación:
/// - **Foreground**: app en primer plano, onMessage
/// - **Background**: app en background, onBackgroundMessage
/// - **Terminated**: app cerrada, onMessageOpenedApp
///
/// setupNotificationHandlers:
/// - onMessage: muestra notificación mientras app activa
/// - onMessageOpenedApp: tap en notificación con app en background
/// - getInitialMessage: tap en notificación con app terminada
/// - Callback onNotificationTap para navegación
///
/// Estructura de payload:
/// ```json
/// {
///   "notification": {
///     "title": "Título",
///     "body": "Mensaje"
///   },
///   "data": {
///     "type": "support",
///     "extra": "data"
///   }
/// }
/// ```
///
/// Uso:
/// ```dart
/// // En main.dart
/// FirebaseAuth.instance.authStateChanges().listen((user) {
///   if (user != null) {
///     sl<FCMService>().initialize();
///   }
/// });
///
/// // Setup handlers
/// WidgetsBinding.instance.addPostFrameCallback((_) {
///   sl<FCMService>().setupNotificationHandlers((type) {
///     if (type == 'support') {
///       navigatorKey.currentState!.pushNamed(Routes.support);
///     }
///   });
/// });
///
/// // Deshabilitar
/// await sl<FCMService>().disableNotifications();
/// ```
class FCMService {
  final FirebaseMessaging _messaging;
  final FirestoreDataSource _firestoreDataSource;
  final FirebaseAuth _auth;

  /// Crea una instancia de [FCMService].
  ///
  /// **Parámetros:**
  /// - [messaging]: Instancia de FirebaseMessaging (opcional, usa default)
  /// - [firestoreDataSource]: Datasource para guardar tokens en Firestore
  /// - [auth]: Instancia de FirebaseAuth (opcional, usa default)
  FCMService({
    FirebaseMessaging? messaging,
    required FirestoreDataSource firestoreDataSource,
    FirebaseAuth? auth,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestoreDataSource = firestoreDataSource,
       _auth = auth ?? FirebaseAuth.instance;

  /// Inicializa FCM y configura el almacenamiento del token.
  ///
  /// Este método debe llamarse al inicio de la aplicación para:
  /// - Solicitar permisos de notificaciones al usuario
  /// - Obtener el token FCM del dispositivo
  /// - Guardar el token en Firestore
  /// - Escuchar cambios futuros en el token
  ///
  /// Los permisos solicitados incluyen: alertas, badges y sonidos.
  Future<void> initialize() async {
    // Solicitar permisos al usuario
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Obtener el token FCM del dispositivo
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }

    // Escuchar cambios en el token (por ejemplo, al reinstalar app)
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
  }

  /// Guarda el token FCM en Firestore asociado al usuario actual.
  ///
  /// Solo guarda el token si hay un usuario autenticado.
  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestoreDataSource.saveFCMToken(user.uid, token);
    }
  }

  /// Habilita las notificaciones push para el usuario.
  ///
  /// Activa auto-inicialización de FCM, solicita permisos y guarda el token.
  /// Útil cuando el usuario activa notificaciones desde ajustes.
  Future<void> enableNotifications() async {
    await _messaging.setAutoInitEnabled(true);
    await initialize();
  }

  /// Deshabilita las notificaciones push para el usuario.
  ///
  /// Realiza las siguientes acciones:
  /// 1. Elimina el token de Firestore (establece a null)
  /// 2. Elimina el token localmente del dispositivo
  /// 3. Desactiva auto-inicialización de FCM
  ///
  /// Útil cuando el usuario desactiva notificaciones desde ajustes.
  /// Los errores se ignoran silenciosamente para no interrumpir la experiencia.
  Future<void> disableNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Eliminar token de Firestore (establecer null)
        await _firestoreDataSource.updateUserProfile(user.uid, {
          'fcmToken': null,
        });
      }
      await _messaging.deleteToken();
      await _messaging.setAutoInitEnabled(false);
    } catch (_) {
      // Ignorar errores, no deben romper la app
    }
  }

  /// Configura listeners para manejar taps en notificaciones.
  ///
  /// Maneja dos escenarios:
  /// 1. **App terminada**: Usuario toca notificación y abre la app
  /// 2. **App en background**: Usuario toca notificación y vuelve a la app
  ///
  /// **Parámetro:**
  /// - [onNotificationTap]: Callback que recibe el tipo de notificación
  ///   (extraído del campo 'type' en data). La app puede usarlo para
  ///   navegar a la pantalla correspondiente.
  ///
  /// **Ejemplo de uso:**
  /// ```dart
  /// fcmService.setupNotificationHandlers((type) {
  ///   if (type == 'new_menu') {
  ///     navigator.pushNamed('/menus');
  ///   } else if (type == 'shopping_reminder') {
  ///     navigator.pushNamed('/shopping');
  ///   }
  /// });
  /// ```
  void setupNotificationHandlers(Function(String? type) onNotificationTap) {
    // Manejar mensaje inicial (cuando la app se abre desde una notificación terminada)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message, onNotificationTap);
      }
    });

    // Cuando la app está en background y se toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message, onNotificationTap);
    });
  }

  /// Procesa un tap en notificación y ejecuta el callback.
  ///
  /// Extrae el campo 'type' del payload de la notificación y lo pasa
  /// al callback para que la app pueda realizar la navegación adecuada.
  void _handleNotificationTap(
    RemoteMessage message,
    Function(String? type) onNotificationTap,
  ) {
    final type = message.data['type'] as String?;
    onNotificationTap(type);
  }
}
