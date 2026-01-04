import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestionar idioma de la aplicación.
///
/// Responsabilidades:
/// - Gestionar Locale actual (es/en)
/// - Persistir preferencia en SharedPreferences
/// - Notificar cambios a la UI para actualizar traducciones
///
/// Persistencia:
/// - Clave: 'languageCode'
/// - Valor: string ('es', 'en')
/// - Se carga automáticamente en constructor
///
/// Idiomas soportados:
/// - **es**: Español (default)
/// - **en**: English
///
/// Funcionamiento:
/// 1. Constructor carga preferencia guardada
/// 2. setLocale(Locale) cambia idioma y persiste
/// 3. MaterialApp escucha locale para aplicar traducciones
/// 4. Toda la app se reconstruye con nuevas traducciones
///
/// Default:
/// - Locale('es') si no hay preferencia guardada
/// - Español como idioma principal de la app
///
/// Uso:
/// ```dart
/// En main.dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => LocaleProvider()),
///   ],
///   child: Consumer<LocaleProvider>(
///     builder: (context, localeProvider, _) => MaterialApp(
///       locale: localeProvider.locale,
///       supportedLocales: [Locale('es'), Locale('en')],
///       localizationsDelegates: AppLocalizations.localizationsDelegates,
///     ),
///   ),
/// )
///
///  En SettingsView
/// final localeProvider = Provider.of<LocaleProvider>(context);
/// DropdownButton<Locale>(
///   value: localeProvider.locale,
///   onChanged: (locale) => localeProvider.setLocale(locale!),
///   items: [
///     DropdownMenuItem(value: Locale('es'), child: Text('Español 🇪🇸')),
///     DropdownMenuItem(value: Locale('en'), child: Text('English 🇬🇧')),
///   ],
/// )
/// ```
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// Carga idioma desde SharedPreferences.
  ///
  /// Default: Locale('es') - Español
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('languageCode') ?? 'es';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Cambia el idioma de la aplicación.
  ///
  /// Parámetros:
  /// - **locale**: nuevo Locale (Locale('es') o Locale('en'))
  ///
  /// Flujo:
  /// 1. Si locale == _locale actual, no hace nada
  /// 2. Actualiza estado local
  /// 3. Notifica listeners (MaterialApp reconstruye con nuevas traducciones)
  /// 4. Persiste en SharedPreferences
  ///
  /// Efecto:
  /// - Toda la UI se actualiza con textos en el nuevo idioma
  /// - AppLocalizations proporciona traducciones según locale
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }
}
