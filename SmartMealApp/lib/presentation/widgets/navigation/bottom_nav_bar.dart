import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Barra de navegación inferior de la app.
///
/// Responsabilidades:
/// - Navegación entre 3 secciones principales
/// - Indicador visual del tab activo
/// - Diseño consistente con theme
///
/// Items de navegación:
/// 1. **Índice 0 - Menús** (restaurant_menu icon):
///    - MenuView: visualizar/generar menú semanal
/// 2. **Índice 1 - Home** (home icon):
///    - HomeView: dashboard principal con 6 cards
/// 3. **Índice 2 - Compras** (shopping_cart icon):
///    - ShoppingView: lista de ingredientes
///
/// Estilo visual:
/// - **Tipo**: BottomNavigationBarType.fixed (3 items siempre visibles)
/// - **Color seleccionado**: primary del theme
/// - **Color no seleccionado**: onSurface con alpha 0.6
/// - **Tamaño iconos**: 24px (seleccionado), 22px (no seleccionado)
/// - **Labels**: solo visible en item seleccionado
///
/// Decoración:
/// - Background: surfaceContainerHighest
/// - Borde superior: outline con alpha 0.2
/// - Sombra superior: BoxShadow sutil
/// - Sin elevation de Material (gestionado con Container)
///
/// Localización:
/// - Labels traducidos con l10n:
///   * navMenus: "Menús" / "Menus"
///   * navHome: "Inicio" / "Home"
///   * navShopping: "Compras" / "Shopping"
///
/// Parámetros:
/// [selectedIndex] - Índice del tab activo (0-2)
/// [onItemSelected] - Callback al seleccionar un tab
///
/// Uso:
/// ```dart
/// BottomNavBar(
///   selectedIndex: 1,
///   onItemSelected: (index) {
///     // Navegar a la pantalla correspondiente
///     NavigationController.navigateToIndex(context, index, currentIndex);
///   },
/// )
/// ```
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: l10n.navMenus,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: l10n.navShopping,
          ),
        ],
      ),
    );
  }
}
