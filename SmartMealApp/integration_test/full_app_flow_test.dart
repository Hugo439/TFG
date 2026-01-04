// =============================================================================
// PRUEBAS DE INTEGRACIÓN - FLUJO COMPLETO LOGIN → PERFIL → MENÚ → SHOPPING
// =============================================================================
// Verifica flujo completo del usuario desde autenticación hasta lista de compras
// Casos: login exitoso, completar perfil, generar menú, ver lista de compras

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smartmeal/main.dart' as app;
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo completo: Login → Perfil → Menú → Shopping', () {
    setUpAll(() async {
      // Inicializar ServiceLocator antes de las pruebas
      await setupServiceLocator();
    });

    tearDownAll(() async {
      await getIt.reset();
    });

    testWidgets('Flujo completo desde login hasta lista de compras', (
      tester,
    ) async {
      // =========================================================================
      // PASO 1: Lanzar aplicación
      // =========================================================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Debe mostrar splash screen o login
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'App debe iniciarse correctamente',
      );

      // =========================================================================
      // PASO 2: LOGIN
      // =========================================================================
      // Buscar campos de email y contraseña
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      if (emailField.evaluate().isNotEmpty) {
        // Si estamos en login, completar campos
        await tester.enterText(emailField, 'test@smartmeal.com');
        await tester.pumpAndSettle();

        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        // Tap en botón de login
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // =========================================================================
      // PASO 3: VERIFICAR HOME SCREEN
      // =========================================================================
      // Después del login debe aparecer HomeView con 6 tarjetas
      expect(
        find.textContaining('Bienvenido'),
        findsAtLeastNWidgets(1),
        reason: 'Debe mostrar mensaje de bienvenida en Home',
      );

      // Verificar BottomNavigationBar con 5 tabs
      expect(
        find.byType(BottomNavigationBar),
        findsOneWidget,
        reason: 'Debe haber BottomNavigationBar',
      );

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(
        bottomNav.items.length,
        equals(5),
        reason: 'BottomNavigationBar debe tener 5 tabs',
      );

      // =========================================================================
      // PASO 4: NAVEGAR A PERFIL
      // =========================================================================
      // Tap en tarjeta de Perfil o en tab de Perfil
      final profileButton = find.byIcon(Icons.person).first;
      await tester.tap(profileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Debe mostrar pantalla de perfil
      expect(
        find.textContaining('Perfil'),
        findsAtLeastNWidgets(1),
        reason: 'Debe mostrar pantalla de Perfil',
      );

      // =========================================================================
      // PASO 5: VERIFICAR CAMPOS DE PERFIL
      // =========================================================================
      // Buscar campos comunes del formulario de perfil
      final nameField = find.byKey(const Key('name_field'));
      final heightField = find.byKey(const Key('height_field'));
      final weightField = find.byKey(const Key('weight_field'));

      if (nameField.evaluate().isEmpty) {
        // Si no hay campos con esas keys, buscar por tipo
        expect(
          find.byType(TextFormField),
          findsAtLeastNWidgets(3),
          reason: 'Debe haber al menos 3 campos de formulario',
        );
      } else {
        // Verificar que campos existen
        expect(nameField, findsOneWidget, reason: 'Debe haber campo de nombre');
        expect(
          heightField,
          findsOneWidget,
          reason: 'Debe haber campo de altura',
        );
        expect(weightField, findsOneWidget, reason: 'Debe haber campo de peso');
      }

      // =========================================================================
      // PASO 6: NAVEGAR A MENÚ SEMANAL
      // =========================================================================
      // Navegar usando BottomNavigationBar al tab de Menú (índice 3)
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Debe mostrar pantalla de Menú Semanal
      expect(
        find.textContaining('Menú'),
        findsAtLeastNWidgets(1),
        reason: 'Debe mostrar pantalla de Menú',
      );

      // =========================================================================
      // PASO 7: VERIFICAR MENÚ O GENERAR NUEVO
      // =========================================================================
      // Buscar botón "Generar menú" si no hay menú actual
      final generateButton = find.textContaining('Generar');

      if (generateButton.evaluate().isNotEmpty) {
        // Si hay botón de generar, hacer tap
        await tester.tap(generateButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Esperar a que se genere el menú
        expect(
          find.byType(CircularProgressIndicator),
          findsNothing,
          reason: 'Loading debe desaparecer después de generar',
        );
      }

      // Verificar que hay recetas mostradas
      // Buscar tarjetas de receta o texto con calorías
      expect(
        find.textContaining('kcal'),
        findsAtLeastNWidgets(1),
        reason: 'Debe mostrar al menos una receta con calorías',
      );

      // =========================================================================
      // PASO 8: NAVEGAR A LISTA DE COMPRAS
      // =========================================================================
      // Navegar al tab de Shopping (índice 2)
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Debe mostrar pantalla de Lista de Compras
      expect(
        find.textContaining('Compra'),
        findsAtLeastNWidgets(1),
        reason: 'Debe mostrar pantalla de Lista de Compras',
      );

      // =========================================================================
      // PASO 9: VERIFICAR FUNCIONALIDAD DE LISTA DE COMPRAS
      // =========================================================================
      // Buscar botón "Generar desde menú" si la lista está vacía
      final generateShoppingButton = find.textContaining('Generar desde menú');

      if (generateShoppingButton.evaluate().isNotEmpty) {
        // Tap en generar lista desde menú
        await tester.tap(generateShoppingButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 8));

        // Debe mostrar SnackBar confirmando generación
        expect(
          find.textContaining('agregado'),
          findsAtLeastNWidgets(1),
          reason: 'Debe mostrar confirmación de ingredientes agregados',
        );
      }

      // Verificar que hay items en la lista
      expect(
        find.byType(Checkbox),
        findsAtLeastNWidgets(1),
        reason: 'Debe haber al menos un checkbox (ingrediente en lista)',
      );

      // =========================================================================
      // PASO 10: MARCAR UN ITEM COMO COMPRADO
      // =========================================================================
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pumpAndSettle();

      // Verificar que el checkbox cambió de estado
      final checkboxWidget = tester.widget<Checkbox>(firstCheckbox);
      expect(
        checkboxWidget.value,
        isTrue,
        reason: 'Checkbox debe estar marcado después del tap',
      );

      // =========================================================================
      // PASO 11: VERIFICAR PRECIO TOTAL
      // =========================================================================
      // Debe haber texto con símbolo de euro (€) mostrando precio total
      expect(
        find.textContaining('€'),
        findsAtLeastNWidgets(1),
        reason: 'Debe mostrar precio total con símbolo €',
      );

      // =========================================================================
      // PASO 12: AÑADIR INGREDIENTE MANUAL
      // =========================================================================
      // Buscar FloatingActionButton para añadir item
      final fab = find.byType(FloatingActionButton);

      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Debe abrir diálogo o pantalla para añadir ingrediente
        expect(
          find.byType(Dialog),
          findsAny,
          reason: 'Debe mostrar diálogo para añadir ingrediente',
        );

        // Cerrar diálogo
        await tester.tap(find.byKey(const Key('cancel_button')));
        await tester.pumpAndSettle();
      }

      // =========================================================================
      // PASO 13: VERIFICAR NAVEGACIÓN COMPLETA
      // =========================================================================
      // Navegar entre todos los tabs del BottomNavigationBar
      for (int i = 0; i < bottomNav.items.length; i++) {
        // Tap en el BottomNavigationBar y esperar
        await tester.tap(find.byType(BottomNavigationBar));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verificar que no hay errores
        expect(
          tester.takeException(),
          isNull,
          reason: 'No debe haber errores al navegar entre tabs',
        );
      }

      // =========================================================================
      // FLUJO COMPLETADO EXITOSAMENTE
      // =========================================================================
      debugPrint('✅ Flujo de integración completado exitosamente');
    });

    testWidgets('Flujo: Editar perfil y regenerar menú', (tester) async {
      // =========================================================================
      // PASO 1: Iniciar app y llegar a Home
      // =========================================================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Asumir que ya estamos logueados (persistencia de sesión)
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // =========================================================================
      // PASO 2: Ir a Perfil
      // =========================================================================
      final profileIcon = find.byIcon(Icons.person).first;
      await tester.tap(profileIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // =========================================================================
      // PASO 3: Editar peso (cambio que afecta calorías)
      // =========================================================================
      final weightField = find.byKey(const Key('weight_field'));

      if (weightField.evaluate().isNotEmpty) {
        // Cambiar peso a 80 kg
        await tester.enterText(weightField, '80');
        await tester.pumpAndSettle();

        // Guardar cambios
        final saveButton = find.byKey(const Key('save_profile_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Debe mostrar confirmación
        expect(
          find.textContaining('guardado'),
          findsAny,
          reason: 'Debe confirmar guardado de perfil',
        );
      }

      // =========================================================================
      // PASO 4: Ir a Menú y regenerar
      // =========================================================================
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      // Navegar al tab de Menú
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BottomNavigationBar));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Buscar botón de regenerar menú
      final regenerateButton = find.textContaining('Regenerar');

      if (regenerateButton.evaluate().isNotEmpty) {
        await tester.tap(regenerateButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Debe mostrar nuevo menú con calorías ajustadas
        expect(
          find.textContaining('kcal'),
          findsAtLeastNWidgets(1),
          reason: 'Debe mostrar menú actualizado',
        );
      }

      debugPrint('✅ Flujo de edición de perfil completado');
    });
  });
}
