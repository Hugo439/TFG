// =============================================================================
// PRUEBAS DE WIDGETS - HOME VIEW
// =============================================================================
// Verifica que el HomeView renderiza correctamente
// Casos: 6 tarjetas, navegación, BottomNavigationBar con 5 tabs, responsive

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/presentation/features/home/view/home_view.dart';
import 'package:smartmeal/presentation/widgets/cards/menu_card.dart';
import 'package:smartmeal/l10n/app_localizations.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

void main() {
  setUpAll(() async {
    // Mock SharedPreferences para evitar MissingPluginException
    SharedPreferences.setMockInitialValues({});
    // Inicializar ServiceLocator para evitar errores
    await setupServiceLocator();
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      locale: const Locale('es'),
      home: child,
    );
  }

  group('HomeView - Renderizado básico', () {
    testWidgets('Debe renderizar HomeView sin errores', (tester) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: No debe haber errores
      expect(find.byType(HomeView), findsOneWidget);
    });

    testWidgets('Debe mostrar el título de bienvenida', (tester) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe aparecer texto de bienvenida
      expect(find.textContaining('Bienvenido'), findsAtLeastNWidgets(1));
    });

    testWidgets('Debe renderizar exactamente 6 tarjetas (MenuCard)', (
      tester,
    ) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber 6 MenuCard
      expect(find.byType(MenuCard), findsNWidgets(6));
    });

    testWidgets('Debe renderizar BottomNavigationBar con 5 tabs', (
      tester,
    ) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber BottomNavigationBar
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verificamos que tiene 5 elementos
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.items.length, equals(5));
    });

    testWidgets('Tab Home (índice 1) debe estar seleccionado', (tester) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: currentIndex debe ser 1 (Home)
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, equals(1));
    });
  });

  group('HomeView - Tarjetas específicas', () {
    testWidgets('Tarjeta de Perfil debe tener ícono person', (tester) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber ícono de persona
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Tarjeta de Menú debe tener ícono restaurant_menu', (
      tester,
    ) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber ícono de menú
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('Tarjeta de Lista de Compras debe tener ícono shopping_cart', (
      tester,
    ) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber ícono de carrito
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('Tarjeta de Estadísticas debe tener ícono bar_chart', (
      tester,
    ) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber ícono de gráfico
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('Tarjeta de Soporte debe tener ícono help_outline', (
      tester,
    ) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber ícono de ayuda
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('Tarjeta de Configuración debe tener ícono settings', (
      tester,
    ) async {
      // Given/When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: Debe haber ícono de ajustes
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });

  group('HomeView - Responsive design', () {
    testWidgets('En pantalla grande (1200px) debe mostrar grid de 4 columnas', (
      tester,
    ) async {
      // Given: Tamaño de pantalla grande
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      // When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: GridView debe tener crossAxisCount = 4
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(4));

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('En pantalla mediana (800px) debe mostrar grid de 3 columnas', (
      tester,
    ) async {
      // Given: Tamaño de pantalla mediana
      await tester.binding.setSurfaceSize(const Size(800, 600));

      // When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: GridView debe tener crossAxisCount = 3
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('En pantalla pequeña (400px) debe mostrar grid de 2 columnas', (
      tester,
    ) async {
      // Given: Tamaño de pantalla pequeña (móvil)
      await tester.binding.setSurfaceSize(const Size(400, 800));

      // When: Construimos HomeView
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // Then: GridView debe tener crossAxisCount = 2
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('HomeView - Interacción', () {
    testWidgets('Tap en tarjeta de Perfil debe intentar navegar', (
      tester,
    ) async {
      // Given: HomeView renderizado
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // When: Hacemos tap en la primera tarjeta (Perfil)
      final profileCard = find.byType(MenuCard).first;
      await tester.tap(profileCard);
      await tester.pumpAndSettle();

      // Then: No debe haber errores (navegación se maneja en la app real)
      // En este test solo verificamos que el tap funciona
      expect(tester.takeException(), isNull);
    });

    testWidgets('Todas las tarjetas deben ser interactivas', (tester) async {
      // Given: HomeView renderizado
      await tester.pumpWidget(buildTestableWidget(const HomeView()));
      await tester.pumpAndSettle();

      // When/Then: Cada MenuCard debe tener onTap
      final cards = tester.widgetList<MenuCard>(find.byType(MenuCard));
      for (final card in cards) {
        expect(card.onTap, isNotNull);
      }
    });
  });

  group('HomeView - Localización', () {
    testWidgets('Debe mostrar textos en español por defecto', (tester) async {
      // Given/When: Construimos HomeView con locale español
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es')],
          locale: const Locale('es'),
          home: const HomeView(),
        ),
      );
      await tester.pumpAndSettle();

      // Then: Debe haber texto en español
      expect(find.textContaining('Perfil'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Menú'), findsAtLeastNWidgets(1));
    });

    testWidgets('Debe soportar cambio a inglés', (tester) async {
      // Given/When: Construimos HomeView con locale inglés
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          home: const HomeView(),
        ),
      );
      await tester.pumpAndSettle();

      // Then: Debe haber texto en inglés
      expect(find.textContaining('Profile'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Menu'), findsAtLeastNWidgets(1));
    });
  });
}
