import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';
import 'package:smartmeal/presentation/routes/routes.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';
import 'package:smartmeal/presentation/features/menu/widgets/stat_card.dart';
import 'package:smartmeal/presentation/features/menu/widgets/weekly_menu_calendar.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<MenuViewModel>(),
      child: const _MenuContent(),
    );
  }
}

class _MenuContent extends StatefulWidget {
  const _MenuContent();

  @override
  State<_MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<_MenuContent> {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vm.errorMessage ?? l10n.menuLoadError,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          if (lastMenu == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.menuEmpty,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.menuEmptyHint,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final colorScheme = Theme.of(context).colorScheme;

          // AppShell ya tiene SingleChildScrollView, solo devolvemos Column
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lastMenu.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.menuCreated}: ${_formatDate(lastMenu.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          if (lastMenu.updatedAt != null)
                            Text(
                              '${l10n.menuUpdated}: ${_formatDate(lastMenu.updatedAt!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                onRecipeTap: (id) => Navigator.of(context).pushNamed(Routes.recipeDetail, arguments: id),
              ),
              const SizedBox(height: 80), // Espacio extra al final
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}