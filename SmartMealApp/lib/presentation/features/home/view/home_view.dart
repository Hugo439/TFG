import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';
import 'package:smartmeal/presentation/routes/routes.dart';
import 'package:smartmeal/presentation/widgets/cards/menu_card.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = _computeCrossAxisCount(width);
    final aspectRatio = _computeChildAspectRatio(width);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AppShell(
      title: l10n.homeTitle,
      subtitle: l10n.homeSubtitle,
      selectedIndex: 1,
      onNavChange: (index) =>
          NavigationController.navigateToIndex(context, index, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeWelcome,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeDescription,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
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
    final l10n = context.l10n;
    switch (index) {
      case 0:
        return MenuCard(
          icon: Icons.person,
          title: l10n.homeCardProfileTitle,
          subtitle: l10n.homeCardProfileSubtitle,
          onTap: () => Navigator.of(context).pushNamed(Routes.profile),
        );
      case 1:
        return MenuCard(
          icon: Icons.restaurant_menu,
          title: l10n.homeCardMenusTitle,
          subtitle: l10n.homeCardMenusSubtitle,
          onTap: () => NavigationController.navigateToMenu(context),
        );
      case 2:
        return MenuCard(
          icon: Icons.shopping_cart,
          title: l10n.homeCardShoppingTitle,
          subtitle: l10n.homeCardShoppingSubtitle,
          onTap: () => NavigationController.navigateToShopping(context),
        );
      case 3:
        return MenuCard(
          icon: Icons.dashboard,
          title: l10n.homeCardStatsTitle,
          subtitle: l10n.homeCardStatsSubtitle,
          onTap: () => Navigator.of(context).pushNamed(Routes.statistics),
        );
      case 4:
        return MenuCard(
          icon: Icons.settings,
          title: l10n.homeCardSettingsTitle,
          subtitle: l10n.homeCardSettingsSubtitle,
          onTap: () => Navigator.of(context).pushNamed(Routes.settings),
        );
      case 5:
        return MenuCard(
          icon: Icons.headset_mic,
          title: l10n.homeCardSupportTitle,
          subtitle: l10n.homeCardSupportSubtitle,
          onTap: () => Navigator.of(context).pushNamed(Routes.support),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
