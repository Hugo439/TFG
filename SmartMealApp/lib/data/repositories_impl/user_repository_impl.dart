import 'dart:io';
import 'package:smartmeal/domain/repositories/user_repository.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';
import 'package:smartmeal/data/mappers/user_profile_mapper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartmeal/core/errors/errors.dart';

/// Implementación del repositorio de perfiles de usuario.
///
/// Gestiona operaciones CRUD sobre perfiles de usuario, coordinando:
/// - Firestore: Almacenamiento de datos del perfil (altura, peso, alergias, etc.)
/// - Firebase Auth: Actualización de displayName y photoURL
/// - Firebase Storage: Subida de fotos de perfil
///
/// El perfil combina datos de Firebase Auth (uid, email, photoURL) con datos
/// personalizados de Firestore (altura, peso, objetivo, alergias, etc.).
///
/// Nota: La actualización del perfil sincroniza datos en Auth y Firestore.
class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreDataSource _firestoreDataSource;

  UserRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required FirestoreDataSource firestoreDataSource,
  }) : _authDataSource = authDataSource,
       _firestoreDataSource = firestoreDataSource;

  /// Obtiene el perfil completo del usuario autenticado.
  ///
  /// Combina datos de Firebase Auth (uid, email, photoURL) con datos
  /// de Firestore (altura, peso, alergias, objetivo, etc.).
  ///
  /// Returns: Entidad [UserProfile] con todos los datos.
  ///
  /// Throws:
  /// - [AuthFailure] si no hay usuario autenticado
  /// - [NotFoundFailure] si el perfil no existe en Firestore
  /// - [ServerFailure] si falla la consulta a Firestore
  @override
  Future<UserProfile> getUserProfile() async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) throw AuthFailure('Usuario no autenticado');

    final data = await _firestoreDataSource.getUserProfile(user.uid);
    if (data == null) throw NotFoundFailure('Perfil no encontrado');

    return UserProfileMapper.fromFirestore(
      data,
      user.uid,
      user.email ?? '',
      user.photoURL,
    );
  }

  /// Actualiza el perfil del usuario autenticado.
  ///
  /// Sincroniza cambios en:
  /// 1. Firestore: Todos los datos del perfil
  /// 2. Firebase Auth: displayName y photoURL (para consistencia)
  ///
  /// [profile] - Entidad con los datos actualizados.
  ///
  /// Throws:
  /// - [AuthFailure] si no hay usuario autenticado
  /// - [ServerFailure] si falla la actualización en Firestore o Auth
  ///
  /// Nota: Si cambia la foto de perfil, primero usar [uploadProfilePhoto]
  /// para subir la imagen y obtener la URL.
  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) throw AuthFailure('Usuario no autenticado');

    await _firestoreDataSource.updateUserProfile(
      user.uid,
      UserProfileMapper.toFirestore(profile),
    );

    // Acceder al value del Value Object DisplayName
    await _authDataSource.updateDisplayName(profile.displayName.value);

    // Si hay photoUrl, actualizar en Firebase Auth también
    if (profile.photoUrl != null) {
      await _authDataSource.updatePhotoURL(profile.photoUrl!);
    }
  }

  /// Crea un nuevo perfil de usuario en Firestore.
  ///
  /// Usado durante el proceso de registro (llamado desde AuthRepository).
  ///
  /// [profile] - Entidad con los datos iniciales del perfil.
  ///
  /// Throws: [ServerFailure] si falla la creación en Firestore.
  @override
  Future<void> createUserProfile(UserProfile profile) async {
    await _firestoreDataSource.createUserProfile(
      profile.uid,
      UserProfileMapper.toFirestoreCreate(profile),
    );
  }

  /// Elimina el perfil de usuario de Firestore.
  ///
  /// [uid] - ID del usuario cuyo perfil se eliminará.
  ///
  /// Throws: [ServerFailure] si falla la eliminación.
  ///
  /// Nota: Esto solo elimina datos de Firestore, no la cuenta de Auth.
  @override
  Future<void> deleteUserProfile(String uid) async {
    await _firestoreDataSource.deleteUserProfile(uid);
  }

  /// Sube una foto de perfil a Firebase Storage.
  ///
  /// [filePath] - Ruta local del archivo de imagen a subir.
  /// [userId] - ID del usuario (usado para organizar archivos en Storage).
  ///
  /// Returns: URL pública de descarga de la imagen subida.
  ///
  /// Throws: [ServerFailure] si falla la subida.
  ///
  /// Nota: Después de subir, usar [updateUserProfile] con la URL retornada
  /// para actualizar el perfil.
  @override
  Future<String> uploadProfilePhoto(String filePath, String userId) async {
    try {
      final file = File(filePath);
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final uploadTask = await storageRef.putFile(file);
      final photoUrl = await uploadTask.ref.getDownloadURL();

      return photoUrl;
    } catch (e) {
      throw ServerFailure('Error al subir foto de perfil: $e');
    }
  }
}
