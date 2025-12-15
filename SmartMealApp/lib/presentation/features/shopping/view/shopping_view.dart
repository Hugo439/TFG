import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/shopping/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_checked_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/set_all_shopping_items_checked_usecase.dart';
import 'package:smartmeal/presentation/features/shopping/viewmodel/shopping_view_model.dart';
import 'package:smartmeal/presentation/features/shopping/view/add_shopping_item_view.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/shopping_header_card.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/shopping_item_card.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/total_price_card.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/delete_checked_dialog.dart';
import 'package:smartmeal/presentation/widgets/layout/app_shell.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingView extends StatelessWidget {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingViewModel(
        sl<GetShoppingItemsUseCase>(),
        sl<AddShoppingItemUseCase>(),
        sl<ToggleShoppingItemUseCase>(),
        sl<GetTotalPriceUseCase>(),
        sl<GenerateShoppingFromMenusUseCase>(),
        sl<DeleteCheckedShoppingItemsUseCase>(),
        sl<SetAllShoppingItemsCheckedUseCase>(),
        FirebaseAuth.instance,
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
    final l10n = context.l10n;

    // Mostrar SnackBar si hay mensaje informativo de menú duplicado
    if (state.infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.infoMessage!),
            duration: const Duration(seconds: 3),
            backgroundColor: colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Limpiar el mensaje para que no se repita
        vm.clearInfoMessage();
      });
    }

    return AppShell(
      title: l10n.shoppingTitle,
      subtitle: l10n.shoppingSubtitle,
      selectedIndex: 2,
      onNavChange: (index) => NavigationController.navigateToIndex(context, index, 2),
      actions: [
        Builder(
          builder: (context) {
            final allChecked = state.items.isNotEmpty && state.items.every((i) => i.isChecked);
            return IconButton(
              icon: Icon(allChecked ? Icons.remove_done : Icons.done_all),
              tooltip: allChecked ? l10n.shoppingUncheckAllTooltip : l10n.shoppingCheckAllTooltip,
              onPressed: state.items.isEmpty
                  ? null
                  : () async {
                      await vm.setAllChecked(!allChecked);
                    },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          tooltip: l10n.shoppingDeleteCheckedTooltip,
          onPressed: state.items.isEmpty || state.checkedItems == 0
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteCheckedDialog(
                      onConfirm: () {
                        vm.deleteCheckedItems();
                      },
                    ),
                  );
                },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShoppingHeaderCard(
            subtitle: l10n.shoppingItemsCount(state.items.length),
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
                  label: Text(l10n.shoppingAddButton),
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
                    final generated = await vm.generateFromMenus();
                    // Solo mostrar el éxito si realmente se generó (no duplicado)
                    if (context.mounted && generated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.shoppingGeneratedFromMenus),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.shoppingGenerateButton),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.shoppingEmptyTitle,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.shoppingEmptySubtitle,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
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
                      onPriceEdited: () {
                        vm.loadShoppingItems();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.shoppingEditPriceSuccess),
                            backgroundColor: colorScheme.primary,
                          ),
                        );
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
            ),
        ],
      ),
    );
  }
}