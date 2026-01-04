import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../routes/routes.dart';

/// Widget raíz de la aplicación SmartMeal.
///
/// Responsabilidades:
/// - Configurar MaterialApp
/// - Multi-idioma (es/en)
/// - Tema claro/oscuro
/// - Localización
/// - Routing
///
/// Providers internos:
/// - ThemeProvider: maneja modo oscuro/claro
/// - LocaleProvider: maneja idioma actual
///
/// MaterialApp configuración:
/// - **title**: "SmartMeal"
/// - **theme**: AppTheme.lightTheme
/// - **darkTheme**: AppTheme.darkTheme
/// - **themeMode**: dinámico según ThemeProvider
/// - **locale**: dinámico según LocaleProvider
/// - **supportedLocales**: es, en
/// - **navigatorKey**: global para navegación externa
/// - **initialRoute**: Routes.splash
/// - **onGenerateRoute**: Routes.onGenerateRoute
///
/// localizationsDelegates:
/// - AppLocalizations.delegate: strings de la app
/// - GlobalMaterialLocalizations: widgets Material
/// - GlobalWidgetsLocalizations: widgets genéricos
/// - GlobalCupertinoLocalizations: widgets iOS
///
/// Consumer2:
/// - Escucha ThemeProvider y LocaleProvider
/// - Reconstruye MaterialApp cuando cambian
/// - Permite cambio de tema/idioma en tiempo real
///
/// navigatorKey:
/// - Inyectado desde main.dart
/// - Permite navegación desde fuera del BuildContext
/// - Usado por FCM para notificaciones push
///
/// Themes:
/// - AppTheme.lightTheme: colores claros
/// - AppTheme.darkTheme: colores oscuros
/// - ThemeMode automático según preferencia del usuario
///
/// Idiomas soportados:
/// - es (Español): idioma por defecto
/// - en (English): idioma secundario
/// - Archivos l10n/app_es.arb y app_en.arb
///
/// Rutas:
/// - Gestionadas por Routes.onGenerateRoute
/// - Splash screen como ruta inicial
/// - Todas las demás rutas definidas en Routes
///
/// Parámetros:
/// [navigatorKey] - GlobalKey para navegación global
///
/// Uso:
/// ```dart
/// runApp(
///   MultiProvider(
///     providers: [...],
///     child: SmartMealApp(navigatorKey: navigatorKey),
///   ),
/// )
/// ```
class SmartMealApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SmartMealApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            title: 'SmartMeal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            locale: localeProvider.locale,
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            navigatorKey: navigatorKey,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
