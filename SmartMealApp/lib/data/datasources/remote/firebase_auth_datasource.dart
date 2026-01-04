import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/core/errors/errors.dart';

/// Datasource que encapsula todas las operaciones con Firebase Authentication.
///
/// Esta clase actúa como wrapper alrededor de [FirebaseAuth], proporcionando:
/// - Operaciones de autenticación (login, registro, logout)
/// - Gestión de cuenta (eliminar, actualizar perfil)
/// - Verificación de estado de autenticación
/// - Obtención del usuario actual
///
/// **Ventajas de esta abstracción:**
/// - Facilita testing (mockeable)
/// - Centraliza manejo de errores de autenticación
/// - Desacopla el código de negocio de Firebase
/// - Permite cambiar proveedor de autenticación fácilmente
class FirebaseAuthDataSource {
  /// Instancia de Firebase Auth.
  final FirebaseAuth _auth;

  /// Crea un [FirebaseAuthDataSource].
  ///
  /// **Parámetro:**
  /// - [auth]: Instancia de FirebaseAuth (opcional, usa default)
  ///
  /// Permite inyección de dependencias para testing.
  FirebaseAuthDataSource({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  /// Inicia sesión con email y contraseña.
  ///
  /// **Parámetros:**
  /// - [email]: Correo electrónico (se normaliza con trim)
  /// - [password]: Contraseña del usuario
  ///
  /// **Retorna:** [UserCredential] con datos del usuario autenticado.
  ///
  /// **Lanza excepciones de FirebaseAuth:**
  /// - `user-not-found`: Email no registrado
  /// - `wrong-password`: Contraseña incorrecta
  /// - `invalid-email`: Formato de email inválido
  /// - `user-disabled`: Cuenta deshabilitada
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registra un nuevo usuario con email y contraseña.
  ///
  /// **Parámetros:**
  /// - [email]: Correo electrónico (se normaliza con trim)
  /// - [password]: Contraseña (mínimo 6 caracteres según Firebase)
  ///
  /// **Retorna:** [UserCredential] con datos del usuario creado.
  ///
  /// **Lanza excepciones de FirebaseAuth:**
  /// - `email-already-in-use`: Email ya registrado
  /// - `weak-password`: Contraseña muy débil
  /// - `invalid-email`: Formato de email inválido
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// Limpia el token de autenticación localmente.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Elimina permanentemente la cuenta del usuario actual.
  ///
  /// **Lanza:** [AuthFailure] si no hay usuario autenticado.
  ///
  /// **Nota:** Esta operación es irreversible. El usuario debe
  /// reautenticarse recientemente para poder eliminar su cuenta.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    ErrorHandler.checkAuth(user);
    await user!.delete();
  }

  /// Obtiene el usuario actualmente autenticado.
  ///
  /// **Retorna:** [User] actual o `null` si no hay sesión activa.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Verifica si hay un usuario autenticado.
  ///
  /// **Retorna:** `true` si hay sesión activa, `false` si no.
  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Actualiza el nombre para mostrar del usuario actual.
  ///
  /// **Parámetro:**
  /// - [displayName]: Nuevo nombre para mostrar
  ///
  /// **Lanza:** [AuthFailure] si no hay usuario autenticado.
  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    ErrorHandler.checkAuth(user);
    await user!.updateDisplayName(displayName);
  }

  /// Actualiza la URL de la foto de perfil del usuario actual.
  ///
  /// **Parámetro:**
  /// - [photoUrl]: URL de la nueva foto de perfil
  ///
  /// **Lanza:** [AuthFailure] si no hay usuario autenticado.
  Future<void> updatePhotoURL(String photoUrl) async {
    final user = _auth.currentUser;
    ErrorHandler.checkAuth(user);
    await user!.updatePhotoURL(photoUrl);
  }
}
