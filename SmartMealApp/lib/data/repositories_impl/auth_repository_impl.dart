import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/data/datasources/local/auth_local_datasource.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/value_objects/email.dart';
import 'package:smartmeal/domain/value_objects/password.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';
import 'package:smartmeal/domain/value_objects/age.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';
import 'package:smartmeal/data/mappers/user_profile_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/errors/errors.dart';

/// Implementación concreta del repositorio de autenticación.
///
/// Esta clase coordina las operaciones de autenticación entre Firebase Auth,
/// Firestore y el almacenamiento local. Sus responsabilidades incluyen:
/// - Autenticación de usuarios (sign in, sign up, sign out)
/// - Creación y gestión de perfiles de usuario
/// - Validación de credenciales mediante Value Objects
/// - Persistencia local de credenciales (para "recordar usuario")
/// - Eliminación de cuentas (auth + datos)
///
/// Flujo de registro:
/// 1. Validar datos con Value Objects
/// 2. Crear usuario en Firebase Auth
/// 3. Actualizar displayName en Auth
/// 4. Crear documento de perfil en Firestore
///
/// Nota: Las validaciones se delegan a los Value Objects (Email, Password, etc.).
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final FirestoreDataSource _firestoreDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required AuthLocalDataSource authLocalDataSource,
    required FirestoreDataSource firestoreDataSource,
  }) : _authDataSource = authDataSource,
       _authLocalDataSource = authLocalDataSource,
       _firestoreDataSource = firestoreDataSource;

  /// Inicia sesión con email y contraseña.
  ///
  /// Valida las credenciales usando Value Objects antes de llamar a Firebase.
  ///
  /// [email] - Dirección de correo electrónico (se validará formato).
  /// [password] - Contraseña del usuario (se validará longitud mínima).
  ///
  /// Throws:
  /// - [ValidationFailure] si email o password son inválidos
  /// - [AuthFailure] si las credenciales son incorrectas (user-not-found, wrong-password)
  /// - [NetworkFailure] si no hay conexión
  @override
  Future<void> signIn({required String email, required String password}) async {
    final emailVO = Email(email);
    final passwordVO = Password(password);

    await _authDataSource.signIn(
      email: emailVO.value,
      password: passwordVO.value,
    );
  }

  /// Registra un nuevo usuario con perfil completo.
  ///
  /// Proceso:
  /// 1. Validar todos los datos con Value Objects
  /// 2. Crear cuenta en Firebase Auth
  /// 3. Actualizar displayName en Auth
  /// 4. Crear documento de perfil en Firestore con todos los datos
  ///
  /// Parámetros requeridos:
  /// [email] - Email válido (se validará formato)
  /// [password] - Contraseña (mínimo 6 caracteres)
  /// [displayName] - Nombre visible del usuario
  /// [heightCm] - Altura en centímetros (50-300)
  /// [weightKg] - Peso en kilogramos (20-500)
  /// [goal] - Objetivo: 'lose_weight', 'maintain_weight', 'gain_weight', 'gain_muscle'
  ///
  /// Parámetros opcionales:
  /// [allergies] - Lista separada por comas de alergias
  /// [age] - Edad del usuario (0-150)
  /// [gender] - 'male' o 'female'
  ///
  /// Throws:
  /// - [ValidationFailure] si algún dato es inválido
  /// - [AuthFailure] si el email ya está en uso (email-already-in-use)
  /// - [ServerFailure] si falla la creación del perfil
  @override
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
  }) async {
    final emailVO = Email(email);
    final passwordVO = Password(password);
    final displayNameVO = DisplayName(displayName);
    final heightVO = Height(heightCm);
    final weightVO = Weight(weightKg);
    final goalVO = Goal.fromString(goal);
    final allergiesVO = Allergies.tryParse(allergies);
    final ageVO = age != null ? Age(age) : null;
    final genderVO = gender != null ? Gender(gender) : null;

    final credential = await _authDataSource.signUp(
      email: emailVO.value,
      password: passwordVO.value,
    );

    final user = credential.user;
    if (user == null) throw ServerFailure('Error al crear usuario');

    await _authDataSource.updateDisplayName(displayNameVO.value);

    final profile = UserProfile(
      uid: user.uid,
      displayName: displayNameVO,
      email: emailVO,
      height: heightVO,
      weight: weightVO,
      goal: goalVO,
      allergies: allergiesVO,
      age: ageVO,
      gender: genderVO,
    );

    await _firestoreDataSource.createUserProfile(
      user.uid,
      UserProfileMapper.toFirestoreCreate(profile),
    );
  }

  /// Verifica si hay un usuario autenticado actualmente.
  ///
  /// Returns: `true` si hay un usuario con sesión activa, `false` en caso contrario.
  @override
  Future<bool> checkAuthStatus() async {
    return _authDataSource.isUserAuthenticated();
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// Limpia el estado de autenticación en Firebase Auth.
  /// Nota: No limpia las credenciales guardadas localmente (usar [clearCredentials] para eso).
  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  /// Elimina completamente la cuenta del usuario.
  ///
  /// Proceso:
  /// 1. Verificar que hay usuario autenticado
  /// 2. Eliminar perfil y todos los datos de Firestore
  /// 3. Eliminar cuenta de Firebase Auth
  ///
  /// Throws:
  /// - [AuthFailure] si no hay usuario autenticado
  /// - [ServerFailure] si falla la eliminación de datos
  ///
  /// Nota: Esta operación es irreversible.
  @override
  Future<void> deleteAccount() async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) throw AuthFailure('Usuario no autenticado');

    await _firestoreDataSource.deleteUserProfile(user.uid);
    await _authDataSource.deleteAccount();
  }

  /// Obtiene el usuario de Firebase Auth actualmente autenticado.
  ///
  /// Returns: Usuario de Firebase Auth o `null` si no hay sesión activa.
  @override
  User? getCurrentUser() {
    return _authDataSource.getCurrentUser();
  }

  /// Guarda las credenciales localmente (para función "Recordar usuario").
  ///
  /// Las credenciales se almacenan de forma segura en el dispositivo usando
  /// flutter_secure_storage.
  ///
  /// [email] - Email a guardar
  /// [password] - Contraseña a guardar (se almacena encriptada)
  ///
  /// Nota: Imprimir logs solo en debug mode.
  @override
  Future<void> saveCredentials(String email, String password) async {
    try {
      if (kDebugMode) {
        print('💾 [AuthRepository] Guardando credenciales...');
      }
      await _authLocalDataSource.saveCredentials(email, password);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthRepository] Error guardando credenciales: $e');
      }
      rethrow;
    }
  }

  /// Elimina las credenciales guardadas localmente.
  ///
  /// Útil cuando el usuario desmarca "Recordar usuario" o cierra sesión.
  ///
  /// Throws: Cualquier error del almacenamiento seguro se re-lanza.
  @override
  Future<void> clearCredentials() async {
    try {
      if (kDebugMode) {
        print('🗑️ [AuthRepository] Limpiando credenciales...');
      }
      await _authLocalDataSource.clearCredentials();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthRepository] Error limpiando credenciales: $e');
      }
      rethrow;
    }
  }

  /// Obtiene las credenciales guardadas localmente.
  ///
  /// Returns:
  /// - Mapa con keys 'email' y 'password' si hay credenciales guardadas
  /// - `null` si no hay credenciales guardadas
  ///
  /// Útil para auto-completar el formulario de login.
  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      if (kDebugMode) {
        print('🔓 [AuthRepository] Obteniendo credenciales guardadas...');
      }
      return await _authLocalDataSource.getSavedCredentials();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthRepository] Error obteniendo credenciales: $e');
      }
      rethrow;
    }
  }
}
