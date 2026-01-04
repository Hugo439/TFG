import 'package:shared_preferences/shared_preferences.dart';

/// Datasource local para credenciales de autenticación.
///
/// Responsabilidad:
/// - Guardar/cargar credenciales si "Recordarme" activado
/// - Almacenar en SharedPreferences (no seguro, solo para comodidad)
///
/// Claves en SharedPreferences:
/// - **remember_me**: bool - si debe recordar credenciales
/// - **saved_email**: string - email guardado
/// - **saved_password**: string - password guardado
///
/// Seguridad:
/// - NO es almacenamiento seguro (password en texto plano)
/// - Solo para conveniencia, no datos sensibles críticos
/// - Para producción, considerar flutter_secure_storage
///
/// Uso:
/// - LoadSavedCredentialsUseCase llama getSavedCredentials()
/// - SaveCredentialsUseCase llama saveCredentials() o clearCredentials()
///
/// Ejemplo:
/// ```dart
/// final ds = AuthLocalDataSource();
///
/// // Guardar credenciales
/// await ds.saveCredentials('user@email.com', 'password123');
///
/// // Cargar credenciales
/// final creds = await ds.getSavedCredentials();
/// if (creds != null) {
///   print('Email: ${creds['email']}');
///   print('Password: ${creds['password']}');
/// }
///
/// // Limpiar al cerrar sesión
/// await ds.clearCredentials();
/// ```
class AuthLocalDataSource {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';

  /// Guarda credenciales en SharedPreferences.
  ///
  /// Marca remember_me = true automáticamente.
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyRememberMe, true);
  }

  /// Limpia credenciales guardadas.
  ///
  /// Marca remember_me = false.
  /// Se llama al cerrar sesión.
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyRememberMe, false);
  }

  Future<bool> shouldRemember() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Obtiene credenciales guardadas.
  ///
  /// Retorna Map con 'email' y 'password' si:
  /// - remember_me == true
  /// - email y password existen
  ///
  /// Retorna null si no hay credenciales guardadas.
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_keyRememberMe) ?? false;

    if (!remember) return null;

    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);

    if (email == null || password == null) return null;

    return {'email': email, 'password': password};
  }
}
