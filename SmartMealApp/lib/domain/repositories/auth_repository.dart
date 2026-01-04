import 'package:firebase_auth/firebase_auth.dart';

/// Contrato para operaciones de autenticación de usuarios.
///
/// Define las operaciones relacionadas con autenticación usando Firebase Auth:
/// - Registro de nuevos usuarios
/// - Inicio de sesión
/// - Cierre de sesión
/// - Eliminación de cuenta
/// - Persistencia de credenciales (remember me)
/// - Verificación de estado de autenticación
///
/// Esta interfaz sigue el Dependency Inversion Principle, permitiendo
/// que la capa de dominio no dependa de Firebase directamente.
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña.
  ///
  /// **Lanza:** [AuthFailure] si las credenciales son inválidas.
  Future<void> signIn({required String email, required String password});

  /// Registra un nuevo usuario y crea su perfil inicial.
  ///
  /// **Parámetros:**
  /// - [email]: Correo electrónico del usuario
  /// - [password]: Contraseña (mínimo 6 caracteres)
  /// - [displayName]: Nombre para mostrar
  /// - [heightCm]: Altura en centímetros
  /// - [weightKg]: Peso en kilogramos
  /// - [goal]: Objetivo nutricional
  /// - [allergies]: Alergias alimentarias (opcional)
  /// - [age]: Edad (opcional, mejora cálculos calóricos)
  /// - [gender]: Género (opcional, mejora cálculos calóricos)
  ///
  /// **Lanza:** [AuthFailure] si el email ya está en uso o hay error.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required int heightCm,
    required double weightKg,
    required String goal,
    String? allergies,
    int? age,
    String? gender,
  });

  /// Verifica si hay un usuario autenticado actualmente.
  ///
  /// **Retorna:** `true` si hay sesión activa, `false` si no.
  Future<bool> checkAuthStatus();

  /// Cierra la sesión del usuario actual.
  Future<void> signOut();

  /// Elimina permanentemente la cuenta del usuario actual.
  ///
  /// Esto incluye:
  /// - Eliminación del usuario en Firebase Auth
  /// - Eliminación del perfil en Firestore
  /// - Limpieza de datos asociados
  Future<void> deleteAccount();

  /// Obtiene el usuario actual de Firebase Auth.
  ///
  /// **Retorna:** El [User] actual o `null` si no hay sesión.
  User? getCurrentUser();

  /// Guarda credenciales localmente para "recordar usuario".
  ///
  /// **Seguridad:** Las contraseñas deben guardarse encriptadas.
  Future<void> saveCredentials(String email, String password);

  /// Elimina las credenciales guardadas localmente.
  Future<void> clearCredentials();

  /// Recupera credenciales guardadas si existen.
  ///
  /// **Retorna:** Map con 'email' y 'password', o `null` si no hay guardadas.
  Future<Map<String, String>?> getSavedCredentials();
}
