import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';
import 'package:smartmeal/presentation/routes/routes.dart';
import '../../../widgets/cards/menu_card.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = _computeCrossAxisCount(width);
    final aspectRatio = _computeChildAspectRatio(width);
    final colorScheme = Theme.of(context).colorScheme;

    return AppShell(
      title: 'SmartMeal',
      subtitle: 'Panel Principal',
      selectedIndex: 1,
      onNavChange: (index) => NavigationController.navigateToIndex(context, index, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenid@',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accede rápidamente a todas las secciones de SmartMeal',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            itemCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (_, i) => _buildCard(context, i),
          ),
        ],
      ),
    );
  }

  int _computeCrossAxisCount(double width) {
    if (width > 1100) return 4;
    if (width > 700) return 3;
    return 2;
  }

  double _computeChildAspectRatio(double width) {
    if (width > 1100) return 1.05;
    if (width > 700) return 1.0;
    return 0.95;
  }

  Widget _buildCard(BuildContext context, int index) {
    switch (index) {
      case 0:
        return MenuCard(
          icon: Icons.person,
          title: 'Perfil',
          subtitle: 'Mi cuenta',
          onTap: () => Navigator.of(context).pushNamed(Routes.profile),
        );
      case 1:
        return MenuCard(
          icon: Icons.restaurant_menu,
          title: 'Menús',
          subtitle: 'Menús semanales',
          onTap: () => NavigationController.navigateToMenu(context),
        );
      case 2:
        return MenuCard(
          icon: Icons.shopping_cart,
          title: 'Lista compra',
          subtitle: 'Productos',
          onTap: () => NavigationController.navigateToShopping(context),
        );
      case 3:
        return const MenuCard(
          icon: Icons.dashboard,
          title: 'Estadísticas',
          subtitle: 'Análisis nutricional',
        );
      case 4:
        return MenuCard(
          icon: Icons.settings,
          title: 'Configuración',
          subtitle: 'Ajustes',
          onTap: () => Navigator.of(context).pushNamed(Routes.settings),
        );
      case 5:
        return const MenuCard(
          icon: Icons.headset_mic,
          title: 'Soporte',
          subtitle: 'Ayuda',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
