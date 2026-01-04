import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Datasource que encapsula operaciones básicas con Cloud Firestore.
///
/// Proporciona métodos CRUD para documentos de usuario en Firestore:
/// - Lectura de perfil de usuario
/// - Creación de nuevo perfil
/// - Actualización de datos del perfil
/// - Eliminación de perfil
/// - Gestión de tokens FCM para notificaciones
///
/// **Responsabilidades:**
/// - Abstraer operaciones de Firestore
/// - Centralizar nombres de colecciones y campos
/// - Facilitar testing con inyección de dependencias
/// - Trabajar con datos crudos (Map<String, dynamic>)
///
/// **Nota:** Esta clase trabaja con datos crudos. La conversión
/// a entidades de dominio se hace en los mappers.
class FirestoreDataSource {
  /// Instancia de Cloud Firestore.
  final FirebaseFirestore _firestore;

  /// Crea un [FirestoreDataSource].
  ///
  /// **Parámetro:**
  /// - [firestore]: Instancia de FirebaseFirestore (opcional, usa default)
  ///
  /// Permite inyección para testing con Firebase Emulator.
  FirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtiene el documento de perfil de un usuario.
  ///
  /// **Parámetro:**
  /// - [uid]: ID del usuario
  ///
  /// **Retorna:** Map con datos del perfil o `null` si no existe.
  ///
  /// **Estructura del documento:**
  /// - `displayName`: Nombre del usuario
  /// - `email`: Correo electrónico
  /// - `height`: Altura en cm
  /// - `weight`: Peso en kg
  /// - `goal`: Objetivo nutricional
  /// - `allergies`: Alergias (opcional)
  /// - `age`: Edad (opcional)
  /// - `gender`: Género (opcional)
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Crea un nuevo documento de perfil de usuario.
  ///
  /// **Parámetros:**
  /// - [uid]: ID del usuario (debe coincidir con Firebase Auth UID)
  /// - [data]: Map con datos del perfil
  ///
  /// Llamado durante el registro de nuevo usuario.
  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .set(data);
  }

  /// Actualiza campos específicos del perfil de usuario.
  ///
  /// **Parámetros:**
  /// - [uid]: ID del usuario
  /// - [data]: Map con campos a actualizar (solo incluir campos modificados)
  ///
  /// Usar `update` en lugar de `set` para no sobrescribir campos no incluidos.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .update(data);
  }

  /// Elimina el documento de perfil de un usuario.
  ///
  /// **Parámetro:**
  /// - [uid]: ID del usuario
  ///
  /// Llamado al eliminar cuenta de usuario.
  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection(AppConstants.collectionUsers).doc(uid).delete();
  }

  /// Guarda el token FCM para notificaciones push.
  ///
  /// **Parámetros:**
  /// - [uid]: ID del usuario
  /// - [token]: Token FCM del dispositivo
  ///
  /// El token se usa para enviar notificaciones específicas al dispositivo del usuario.
  Future<void> saveFCMToken(String uid, String token) async {
    await _firestore.collection(AppConstants.collectionUsers).doc(uid).update({
      AppConstants.fieldFcmToken: token,
    });
  }
}
