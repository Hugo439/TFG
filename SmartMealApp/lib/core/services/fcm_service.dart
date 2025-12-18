import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';

class FCMService {
  final FirebaseMessaging _messaging;
  final FirestoreDataSource _firestoreDataSource;
  final FirebaseAuth _auth;

  FCMService({
    FirebaseMessaging? messaging,
    required FirestoreDataSource firestoreDataSource,
    FirebaseAuth? auth,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestoreDataSource = firestoreDataSource,
       _auth = auth ?? FirebaseAuth.instance;

  /// Inicializa FCM y guarda el token en Firestore
  Future<void> initialize() async {
    // Solicitar permisos
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Obtener el token FCM
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }

    // Escuchar cambios en el token
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestoreDataSource.saveFCMToken(user.uid, token);
    }
  }

  /// Habilita notificaciones: activa auto-init, pide permiso, guarda token
  Future<void> enableNotifications() async {
    await _messaging.setAutoInitEnabled(true);
    await initialize();
  }

  /// Deshabilita notificaciones: borra token local y en Firestore y desactiva auto-init
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
}
