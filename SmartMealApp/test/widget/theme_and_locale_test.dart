// =============================================================================
// PRUEBAS DE WIDGETS - TEMA Y LOCALIZACIÓN
// =============================================================================
// Verifica cambios de tema (light/dark) y localización (es/en)
// Casos: ThemeProvider, LocaleProvider, cambios dinámicos

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/theme/theme_provider.dart';
import 'package:smartmeal/presentation/app/locale_provider.dart';
import 'package:smartmeal/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('ThemeProvider - Cambio de tema', () {
    testWidgets('Debe iniciar con tema claro por defecto', (tester) async {
      // Given: ThemeProvider nuevo
      final themeProvider = ThemeProvider();

      // When: Construimos widget con Provider
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                themeMode: provider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: Scaffold(body: Text('Dark: ${provider.isDarkMode}')),
              );
            },
          ),
        ),
      );

      // Then: Debe estar en modo claro
      expect(themeProvider.isDarkMode, isFalse);
    });

    testWidgets('Debe cambiar a tema oscuro al llamar toggleTheme', (
      tester,
    ) async {
      // Given: ThemeProvider en modo claro
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                themeMode: provider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: Scaffold(
                  body: Column(
                    children: [
                      Text('Mode: ${provider.isDarkMode}'),
                      ElevatedButton(
                        onPressed: () => provider.toggleTheme(true),
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // When: Hacemos tap en el botón para cambiar tema
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Then: Debe cambiar a modo oscuro
      expect(themeProvider.isDarkMode, isTrue);
    });

    testWidgets('Debe alternar entre claro y oscuro múltiples veces', (
      tester,
    ) async {
      // Given: ThemeProvider
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                themeMode: provider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => provider.toggleTheme(true),
                        child: const Text('Dark'),
                      ),
                      ElevatedButton(
                        onPressed: () => provider.toggleTheme(false),
                        child: const Text('Light'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // When: Alternamos varias veces
      expect(themeProvider.isDarkMode, isFalse); // Inicial: claro

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(themeProvider.isDarkMode, isTrue); // Primer toggle: oscuro

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(themeProvider.isDarkMode, isFalse); // Segundo toggle: claro

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(themeProvider.isDarkMode, isTrue); // Tercer toggle: oscuro
    });

    testWidgets('UI debe reaccionar al cambio de tema', (tester) async {
      // Given: Widget que usa colors del tema
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                themeMode: provider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                home: Builder(
                  builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Scaffold(
                      backgroundColor: colorScheme.surface,
                      body: Column(
                        children: [
                          Container(
                            key: const Key('test_container'),
                            color: colorScheme.primary,
                            width: 100,
                            height: 100,
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                provider.toggleTheme(!provider.isDarkMode),
                            child: const Text('Toggle'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // When: Obtenemos color inicial
      final initialContainer = tester.widget<Container>(
        find.byKey(const Key('test_container')),
      );
      final initialColor = initialContainer.color;

      // Cambiamos tema
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Then: Color debe haber cambiado
      final newContainer = tester.widget<Container>(
        find.byKey(const Key('test_container')),
      );
      final newColor = newContainer.color;

      expect(newColor, isNot(equals(initialColor)));
    });
  });

  group('LocaleProvider - Cambio de idioma', () {
    testWidgets('Debe iniciar con español por defecto', (tester) async {
      // Given: LocaleProvider nuevo
      final localeProvider = LocaleProvider();

      // When: Construimos widget
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: Consumer<LocaleProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                locale: provider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es'), Locale('en')],
                home: Scaffold(body: Text('Locale: ${provider.locale}')),
              );
            },
          ),
        ),
      );

      // Then: Debe estar en español
      expect(localeProvider.locale.languageCode, equals('es'));
    });

    testWidgets('Debe cambiar a inglés al llamar setLocale', (tester) async {
      // Given: LocaleProvider en español
      final localeProvider = LocaleProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: Consumer<LocaleProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                locale: provider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es'), Locale('en')],
                home: Scaffold(
                  body: Column(
                    children: [
                      Text('Locale: ${provider.locale.languageCode}'),
                      ElevatedButton(
                        onPressed: () => provider.setLocale(const Locale('en')),
                        child: const Text('To English'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // When: Cambiamos a inglés
      await tester.tap(find.text('To English'));
      await tester.pumpAndSettle();

      // Then: Debe estar en inglés
      expect(localeProvider.locale.languageCode, equals('en'));
    });

    testWidgets('Textos deben cambiar al cambiar idioma', (tester) async {
      // Given: LocaleProvider en español
      final localeProvider = LocaleProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: Consumer<LocaleProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                locale: provider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es'), Locale('en')],
                home: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Scaffold(
                      body: Column(
                        children: [
                          Text(l10n.homeTitle, key: const Key('home_title')),
                          ElevatedButton(
                            onPressed: () =>
                                provider.setLocale(const Locale('en')),
                            child: const Text('To English'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                provider.setLocale(const Locale('es')),
                            child: const Text('To Spanish'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // When: Obtenemos texto en español
      final spanishText = tester
          .widget<Text>(find.byKey(const Key('home_title')))
          .data;

      // Cambiamos a inglés
      await tester.tap(find.text('To English'));
      await tester.pumpAndSettle();

      final englishText = tester
          .widget<Text>(find.byKey(const Key('home_title')))
          .data;

      // Then: Textos deben ser diferentes
      expect(spanishText, isNot(equals(englishText)));
    });

    testWidgets('Debe alternar entre idiomas correctamente', (tester) async {
      // Given: LocaleProvider
      final localeProvider = LocaleProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: Consumer<LocaleProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                locale: provider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es'), Locale('en')],
                home: Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => provider.setLocale(const Locale('en')),
                        child: const Text('English'),
                      ),
                      ElevatedButton(
                        onPressed: () => provider.setLocale(const Locale('es')),
                        child: const Text('Español'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // When: Alternamos entre idiomas
      expect(localeProvider.locale.languageCode, equals('es')); // Inicial

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(localeProvider.locale.languageCode, equals('en'));

      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();
      expect(localeProvider.locale.languageCode, equals('es'));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(localeProvider.locale.languageCode, equals('en'));
    });
  });

  group('ThemeProvider + LocaleProvider - Integración', () {
    testWidgets('Debe soportar cambio simultáneo de tema e idioma', (
      tester,
    ) async {
      // Given: Ambos providers
      final themeProvider = ThemeProvider();
      final localeProvider = LocaleProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
          ],
          child: Consumer2<ThemeProvider, LocaleProvider>(
            builder: (context, theme, locale, _) {
              return MaterialApp(
                themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                locale: locale.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es'), Locale('en')],
                home: Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        key: const Key('toggle_theme'),
                        onPressed: () => theme.toggleTheme(true),
                        child: const Text('Toggle Theme'),
                      ),
                      ElevatedButton(
                        key: const Key('change_locale'),
                        onPressed: () => locale.setLocale(const Locale('en')),
                        child: const Text('To English'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // When: Cambiamos ambos
      expect(themeProvider.isDarkMode, isFalse);
      expect(localeProvider.locale.languageCode, equals('es'));

      await tester.tap(find.byKey(const Key('toggle_theme')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('change_locale')));
      await tester.pumpAndSettle();

      // Then: Ambos deben haber cambiado
      expect(themeProvider.isDarkMode, isTrue);
      expect(localeProvider.locale.languageCode, equals('en'));
    });
  });
}
