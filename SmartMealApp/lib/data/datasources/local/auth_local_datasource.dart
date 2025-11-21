import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyRememberMe, true);
  }

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