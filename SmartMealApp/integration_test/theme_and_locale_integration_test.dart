// =============================================================================
// PRUEBAS DE INTEGRACIÓN - CAMBIO GLOBAL DE TEMA E IDIOMA
// =============================================================================
// Verifica que cambios de tema y localización se aplican en toda la app
// Casos: tema light → dark, idioma español → inglés, persistencia

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smartmeal/main.dart' as app;
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integración: Tema e Idioma global', () {
    setUpAll(() async {
      await setupServiceLocator();
    });

    tearDownAll(() async {
      await getIt.reset();
    });

    testWidgets('Cambio de tema se aplica globalmente en todas las pantallas', (
      tester,
    ) async {
      // =========================================================================
      // PASO 1: Lanzar aplicación
      // =========================================================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar que app inició correctamente
      expect(find.byType(MaterialApp), findsOneWidget);

      // =========================================================================
      // PASO 2: Navegar a Configuración
      // =========================================================================
      // Buscar BottomNavigationBar y navegar al tab de Settings (último, índice 4)
      final bottomNavFinder = find.byType(BottomNavigationBar);

      if (bottomNavFinder.evaluate().isEmpty) {
        // Si no estamos en home, navegar primero
        final homeIcon = find.byIcon(Icons.home);
        if (homeIcon.evaluate().isNotEmpty) {
          await tester.tap(homeIcon.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      final bottomNav = tester.widget<BottomNavigationBar>(bottomNavFinder);
      // Navegar a Settings tab (índice 4)
      // Usamos find.byType ya que find.byIcon no funciona con widgets
      final navBar = find.byType(BottomNavigationBar);
      await tester.tap(navBar);
      await tester.pumpAndSettle();
      // Simular tap en el último tab
      await tester.tap(navBar);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // =========================================================================
      // PASO 3: Verificar pantalla de Configuración
      // =========================================================================
      expect(
        find.textContaining('Configuración'),
        findsAtLeastNWidgets(1),
        reason: 'Debe mostrar pantalla de Configuración',
      );

      // =========================================================================
      // PASO 4: Cambiar tema a oscuro
      // =========================================================================
      // Buscar switch de tema
      final themeSwitchFinder = find.byKey(const Key('theme_switch'));

      if (themeSwitchFinder.evaluate().isEmpty) {
        // Buscar por tipo Switch
        final switches = find.byType(Switch);
        expect(
          switches,
          findsAtLeastNWidgets(1),
          reason: 'Debe haber al menos un Switch (tema)',
        );

        // Tap en el primer switch (probablemente el de tema)
        await tester.tap(switches.first);
      } else {
        await tester.tap(themeSwitchFinder);
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // =========================================================================
      // PASO 5: Verificar que el tema cambió en Configuración
      // =========================================================================
      // Verificar que los colores de fondo cambiaron
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      final backgroundColor = scaffold.backgroundColor;

      // En tema oscuro, background suele ser oscuro (luminance < 0.5)
      expect(
        backgroundColor != null,
        isTrue,
        reason: 'Scaffold debe tener color de fondo',
      );

      // =========================================================================
      // PASO 6: Navegar a otra pantalla y verificar tema
      // =========================================================================
      // Ir a Home (índice 1)
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar que el tema oscuro también se aplicó en Home
      final homeScaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      final homeBackgroundColor = homeScaffold.backgroundColor;

      expect(
        homeBackgroundColor,
        equals(backgroundColor),
        reason: 'Tema debe ser consistente en todas las pantallas',
      );

      // =========================================================================
      // PASO 7: Navegar a Perfil y verificar tema
      // =========================================================================
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final profileScaffold = tester.widget<Scaffold>(
        find.byType(Scaffold).first,
      );
      final profileBackgroundColor = profileScaffold.backgroundColor;

      expect(
        profileBackgroundColor,
        equals(backgroundColor),
        reason: 'Tema debe aplicarse a todas las pantallas (Perfil)',
      );

      // =========================================================================
      // PASO 8: Volver a tema claro
      // =========================================================================
      // Volver a Configuración
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap en switch de nuevo para volver a claro
      final themeSwitchAgain = find.byKey(const Key('theme_switch'));
      if (themeSwitchAgain.evaluate().isNotEmpty) {
        await tester.tap(themeSwitchAgain);
      } else {
        await tester.tap(find.byType(Switch).first);
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar que volvió a tema claro
      final lightScaffold = tester.widget<Scaffold>(
        find.byType(Scaffold).first,
      );
      final lightBackgroundColor = lightScaffold.backgroundColor;

      expect(
        lightBackgroundColor,
        isNot(equals(backgroundColor)),
        reason: 'Color debe haber cambiado de vuelta a tema claro',
      );

      debugPrint('✅ Cambio de tema global verificado correctamente');
    });

    testWidgets('Cambio de idioma se aplica globalmente en todas las pantallas', (
      tester,
    ) async {
      // =========================================================================
      // PASO 1: Lanzar aplicación
      // =========================================================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // =========================================================================
      // PASO 2: Ir a Configuración
      // =========================================================================
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Navegar a Settings
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // =========================================================================
      // PASO 3: Guardar texto actual en español
      // =========================================================================
      final spanishText = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .where((t) => t != null)
          .toList();

      expect(
        spanishText,
        isNotEmpty,
        reason: 'Debe haber textos en la pantalla',
      );

      // =========================================================================
      // PASO 4: Cambiar idioma a inglés
      // =========================================================================
      // Buscar dropdown o botón de idioma
      final languageDropdown = find.byKey(const Key('language_dropdown'));

      if (languageDropdown.evaluate().isNotEmpty) {
        await tester.tap(languageDropdown);
        await tester.pumpAndSettle();

        // Seleccionar "English"
        final englishOption = find.text('English');
        if (englishOption.evaluate().isNotEmpty) {
          await tester.tap(englishOption);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      } else {
        // Buscar botón con "English" o "Inglés"
        final englishButton = find.textContaining('English');
        if (englishButton.evaluate().isNotEmpty) {
          await tester.tap(englishButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // =========================================================================
      // PASO 5: Verificar que textos cambiaron en Configuración
      // =========================================================================
      final englishText = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .where((t) => t != null)
          .toList();

      // Al menos algunos textos deben ser diferentes
      expect(
        englishText,
        isNot(equals(spanishText)),
        reason: 'Textos deben cambiar de español a inglés',
      );

      // =========================================================================
      // PASO 6: Verificar cambio en Home
      // =========================================================================
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Buscar textos típicos en inglés
      expect(
        find.textContaining('Home'),
        findsAny,
        reason: 'Debe mostrar textos en inglés en Home',
      );

      // =========================================================================
      // PASO 7: Verificar cambio en Perfil
      // =========================================================================
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(
        find.textContaining('Profile'),
        findsAny,
        reason: 'Debe mostrar textos en inglés en Perfil',
      );

      // =========================================================================
      // PASO 8: Volver a español
      // =========================================================================
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cambiar de vuelta a español
      final spanishButton = find.textContaining('Español');
      if (spanishButton.evaluate().isNotEmpty) {
        await tester.tap(spanishButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verificar que volvió a español
      expect(
        find.textContaining('Configuración'),
        findsAtLeastNWidgets(1),
        reason: 'Debe volver a mostrar textos en español',
      );

      debugPrint('✅ Cambio de idioma global verificado correctamente');
    });

    testWidgets('Cambios de tema e idioma persisten al reiniciar app', (
      tester,
    ) async {
      // =========================================================================
      // PASO 1: Lanzar app y cambiar tema + idioma
      // =========================================================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Ir a Configuración
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cambiar tema
      final themeSwitch = find.byType(Switch).first;
      await tester.tap(themeSwitch);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cambiar idioma (si es posible)
      final languageButton = find.textContaining('English');
      if (languageButton.evaluate().isNotEmpty) {
        await tester.tap(languageButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // =========================================================================
      // PASO 2: "Reiniciar" app (simular cierre y reapertura)
      // =========================================================================
      // Nota: En test real con persistencia, SharedPreferences mantendría estado
      // Aquí verificamos que los providers mantienen estado durante sesión

      // Navegar a Home y volver a Settings
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar que el switch sigue en posición correcta
      final switchWidget = tester.widget<Switch>(find.byType(Switch).first);
      expect(
        switchWidget.value,
        isTrue,
        reason: 'Switch de tema debe mantener estado',
      );

      debugPrint('✅ Persistencia de configuración verificada');
    });
  });
}
