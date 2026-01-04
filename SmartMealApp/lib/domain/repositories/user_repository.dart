import 'package:smartmeal/domain/entities/user_profile.dart';

/// Contrato para operaciones CRUD sobre perfiles de usuario.
///
/// Gestiona la persistencia del [UserProfile] en Firestore, incluyendo:
/// - Lectura del perfil actual
/// - Actualización de datos personales
/// - Creación de perfil inicial
/// - Eliminación de perfil
/// - Subida de foto de perfil
///
/// El perfil contiene información nutricional y personal necesaria
/// para generar menús personalizados.
abstract class UserRepository {
  /// Obtiene el perfil del usuario autenticado actualmente.
  ///
  /// **Lanza:**
  /// - [AuthFailure] si no hay usuario autenticado
  /// - [NotFoundFailure] si el perfil no existe en Firestore
  Future<UserProfile> getUserProfile();

  /// Actualiza el perfil del usuario con nuevos datos.
  ///
  /// **Parámetro:**
  /// - [profile]: Perfil con datos actualizados
  ///
  /// Permite modificar peso, altura, objetivo, alergias, etc.
  Future<void> updateUserProfile(UserProfile profile);

  /// Crea un nuevo perfil de usuario en Firestore.
  ///
  /// **Parámetro:**
  /// - [profile]: Perfil inicial del usuario
  ///
  /// Llamado automáticamente durante el registro.
  Future<void> createUserProfile(UserProfile profile);

  /// Elimina el perfil de un usuario de Firestore.
  ///
  /// **Parámetro:**
  /// - [uid]: ID del usuario cuyo perfil se eliminará
  ///
  /// Usado al eliminar cuenta.
  Future<void> deleteUserProfile(String uid);

  /// Sube una foto de perfil a Firebase Storage.
  ///
  /// **Parámetros:**
  /// - [filePath]: Ruta local del archivo de imagen
  /// - [userId]: ID del usuario propietario
  ///
  /// **Retorna:** URL pública de la imagen subida.
  Future<String> uploadProfilePhoto(String filePath, String userId);
}
