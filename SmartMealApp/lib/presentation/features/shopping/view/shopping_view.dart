import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/presentation/features/shopping/viewmodel/shopping_view_model.dart';
import 'package:smartmeal/presentation/features/shopping/view/add_shopping_item_view.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/shopping_header_card.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/shopping_item_card.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/total_price_card.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';

class ShoppingView extends StatelessWidget {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingViewModel(
        sl<GetShoppingItemsUseCase>(),
        sl<AddShoppingItemUseCase>(),
        sl<ToggleShoppingItemUseCase>(),
        sl<DeleteShoppingItemUseCase>(),
        sl<GetTotalPriceUseCase>(),
        sl<GenerateShoppingFromMenusUseCase>(),
      )..loadShoppingItems(),
      child: const _ShoppingContent(),
    );
  }
}

class _ShoppingContent extends StatelessWidget {
  const _ShoppingContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShoppingViewModel>();
    final state = vm.state;
    final colorScheme = Theme.of(context).colorScheme;

    return AppShell(
      title: 'Lista de la Compra',
      subtitle: 'Productos',
      selectedIndex: 2,
      onNavChange: (index) => NavigationController.navigateToIndex(context, index, 2),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShoppingHeaderCard(
            subtitle: '${state.items.length} productos',
          ),
          const SizedBox(height: 16),
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddShoppingItemView(),
                      ),
                    );
                    if (result == true) {
                      vm.loadShoppingItems();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await vm.generateFromMenus();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Lista generada desde menús'),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de items
          if (state.status == ShoppingStatus.loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lista vacía',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añade productos o genera desde menús',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              itemBuilder: (_, index) {
                final item = state.items[index];
                return ShoppingItemCard(
                  item: item,
                  onCheckChanged: (checked) {
                    vm.toggleItem(item.id, checked ?? false);
                  },
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddShoppingItemView(itemToEdit: item),
                      ),
                    );
                    if (result == true) {
                      vm.loadShoppingItems();
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TotalPriceCard(
              totalPrice: state.totalPrice,
              checkedCount: state.items.where((i) => i.isChecked).length,
              totalCount: state.items.length,
            ),
          ],
        ],
      ),
    );
  }
}