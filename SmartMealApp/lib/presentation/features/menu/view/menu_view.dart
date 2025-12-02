import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';
import 'package:smartmeal/presentation/features/menu/widgets/stat_card.dart';
import 'package:smartmeal/presentation/features/menu/widgets/weekly_menu_calendar.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuViewModel>(
      create: (_) => MenuViewModel(),
      child: const _MenuContent(),
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MenuViewModel>(context);
    final user = Provider.of<User?>(context);
    final lastMenu = vm.menus.isNotEmpty ? vm.menus.first : null;
    final l10n = context.l10n;

    return AppShell(
      title: l10n.menuTitle,
      subtitle: l10n.menuSubtitle,
      selectedIndex: 0,
      onNavChange: (index) => NavigationController.navigateToIndex(context, index, 0),
      body: Builder(
        builder: (context) {
          if (vm.state == MenuState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == MenuState.error) {
            return Center(
              child: Text(
                vm.errorMessage ?? l10n.menuLoadError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          if (lastMenu == null) {
            return Center(
              child: Text(
                l10n.menuEmpty,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            );
          }

          final colorScheme = Theme.of(context).colorScheme;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department,
                      value: '${lastMenu.totalWeeklyCalories} kcal',
                      label: l10n.menuTotalCalories,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.trending_up,
                      value: '${lastMenu.avgDailyCalories.toInt()} kcal',
                      label: l10n.menuAvgDaily,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              WeeklyMenuCalendar(
                menu: lastMenu,
                onRecipeTap: (id) => Navigator.of(context).pushNamed('/recipe-detail', arguments: id),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: l10n.menuGenerateTooltip,
          onPressed: () {
            Navigator.of(context).pushNamed('/generate-menu').then((result) {
              if (!context.mounted) return;
              final userId = user?.uid ?? '';
              if (result == true && userId.isNotEmpty) {
                vm.loadWeeklyMenus(userId);
              }
            });
          },
        ),
      ],
    );
  }
}