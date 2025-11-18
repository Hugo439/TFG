import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/theme/colors.dart';
import '../../../widgets/cards/menu_card.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = _computeCrossAxisCount(width);
    final aspectRatio = _computeChildAspectRatio(width);
    final cards = _buildCards();

    return AppShell(
      title: 'SmartMeal',
      subtitle: 'Panel Principal',
      selectedIndex: _selectedIndex,
      onNavChange: (index) {
        setState(() => _selectedIndex = index);
        _handleNavigation(index);
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenid@',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accede rápidamente a todas las secciones de SmartMeal',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (_, i) => cards[i],
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

  List<Widget> _buildCards() {
    return const [
      MenuCard(icon: Icons.dashboard,       title: 'Otra cosa',       subtitle: 'Descripcion otra cosa'),
      MenuCard(icon: Icons.person,          title: 'Perfil',          subtitle: 'Mi cuenta'),
      MenuCard(icon: Icons.restaurant_menu, title: 'Menús',           subtitle: 'Menús semanales'),
      MenuCard(icon: Icons.settings,        title: 'Configuración',   subtitle: 'Ajustes'),
      MenuCard(icon: Icons.shopping_cart,   title: 'Lista compra',    subtitle: 'Productos'),
      MenuCard(icon: Icons.headset_mic,     title: 'Soporte',         subtitle: 'Ayuda'),
    ];
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: /* TODO: Menús */ break;
      case 1: /* Home */ break;
      case 2: /* TODO: Lista */ break;
    }
  }
}
