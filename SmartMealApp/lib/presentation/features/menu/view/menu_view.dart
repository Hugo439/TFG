import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/get_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/get_recommended_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_menu_item_usecase.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/presentation/features/menu/widgets/menu_management_card.dart';
import 'package:smartmeal/presentation/features/menu/widgets/recommended_section.dart';
import 'package:smartmeal/presentation/features/menu/widgets/menu_item_card.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuViewModel(
        sl<GetMenuItemsUseCase>(),
        sl<GetRecommendedMenuItemsUseCase>(),
        sl<DeleteMenuItemUseCase>(),
      )..loadMenuItems(),
      child: const _MenuContent(),
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MenuViewModel>();
    final state = vm.state;
    final colorScheme = Theme.of(context).colorScheme;

    return AppShell(
      title: 'Menús',
      subtitle: 'Gestión de menús',
      selectedIndex: 0,
      onNavChange: (index) => NavigationController.navigateToIndex(context, index, 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuManagementCard(
            onTap: () {
              // TODO: Navegar a crear menú
            },
          ),
          const SizedBox(height: 24),
          if (state.status == MenuStatus.loading && state.menuItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.status == MenuStatus.error)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64, 
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error ?? 'Error al cargar menús',
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: vm.loadMenuItems,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            RecommendedSection(
              menuCount: state.recommendedItems.length,
            ),
            const SizedBox(height: 24),
            Text(
              'Mis Menús',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (state.menuItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64, 
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes menús aún',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primer menú semanal',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final item = state.menuItems[index];
                  return MenuItemCard(
                    menuItem: item,
                    onMoreTap: () {
                      _showMenuOptions(context, vm, item.id);
                    },
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  void _showMenuOptions(BuildContext context, MenuViewModel vm, String menuId) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: colorScheme.primary),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a editar menú
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: colorScheme.error),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(context);
                vm.deleteMenuItem(menuId);
              },
            ),
          ],
        ),
      ),
    );
  }
}