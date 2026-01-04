import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestionar tema de la aplicación (claro/oscuro).
///
/// Responsabilidades:
/// - Gestionar estado del tema (light/dark)
/// - Persistir preferencia en SharedPreferences
/// - Notificar cambios a la UI
///
/// Persistencia:
/// - Clave: 'theme_mode'
/// - Valor: bool (true = dark, false = light)
/// - Se carga automáticamente en constructor
///
/// Funcionamiento:
/// 1. Constructor carga preferencia guardada
/// 2. toggleTheme(bool) cambia tema y persiste
/// 3. MaterialApp escucha isDarkMode para aplicar ThemeData
///
/// Default:
/// - false (tema claro)
/// - Se aplica si no hay preferencia guardada
///
/// Uso:
/// ```dart
/// // En main.dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => ThemeProvider()),
///   ],
///   child: Consumer<ThemeProvider>(
///     builder: (context, themeProvider, _) => MaterialApp(
///       theme: AppTheme.lightTheme,
///       darkTheme: AppTheme.darkTheme,
///       themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
///     ),
///   ),
/// )
///
/// // En SettingsView
/// final themeProvider = Provider.of<ThemeProvider>(context);
/// Switch(
///   value: themeProvider.isDarkMode,
///   onChanged: themeProvider.toggleTheme,
/// )
/// ```
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Carga preferencia de tema desde SharedPreferences.
  ///
  /// Default: false (tema claro)
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  /// Cambia el tema de la aplicación.
  ///
  /// Parámetros:
  /// - **isDark**: true = tema oscuro, false = tema claro
  ///
  /// Flujo:
  /// 1. Actualiza estado local
  /// 2. Notifica listeners (MaterialApp reconstruye)
  /// 3. Persiste en SharedPreferences
  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}
