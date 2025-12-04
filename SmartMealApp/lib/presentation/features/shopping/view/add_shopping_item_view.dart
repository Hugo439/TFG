import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/presentation/features/shopping/viewmodel/add_shopping_item_view_model.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/presentation/widgets/buttons/primary_button.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class AddShoppingItemView extends StatelessWidget {
  final ShoppingItem? itemToEdit;

  const AddShoppingItemView({super.key, this.itemToEdit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddShoppingItemViewModel(
        sl<AddShoppingItemUseCase>(),
        itemToEdit,
      ),
      child: const _AddShoppingItemContent(),
    );
  }
}

class _AddShoppingItemContent extends StatelessWidget {
  const _AddShoppingItemContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddShoppingItemViewModel>();
    final isEdit = vm.itemToEdit != null;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? l10n.shoppingEditTitle : l10n.shoppingAddTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Nombre del producto
            Text(
              l10n.shoppingProductNameLabel,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: l10n.shoppingProductNameHint,
              initialValue: vm.name,
              onChanged: vm.setName,
              prefixIcon: Icons.shopping_cart,
            ),
            const SizedBox(height: 16),

            // Cantidad
            Text(
              l10n.shoppingQuantityLabel,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: l10n.shoppingQuantityHint,
              initialValue: vm.quantity,
              onChanged: vm.setQuantity,
              prefixIcon: Icons.scale,
            ),
            const SizedBox(height: 16),

            // Precio
            Text(
              l10n.shoppingPriceLabel,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: l10n.shoppingPriceHint,
              initialValue: vm.price,
              onChanged: vm.setPrice,
              prefixIcon: Icons.euro,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Categoría
            Text(
              l10n.shoppingCategoryLabel,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _CategoryDropdown(
              value: vm.category,
              onChanged: vm.setCategory,
            ),
            const SizedBox(height: 16),

            // Para qué menús
            Text(
              l10n.shoppingMenusLabel,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: l10n.shoppingMenusHint,
              initialValue: vm.usedInMenus,
              onChanged: vm.setUsedInMenus,
              prefixIcon: Icons.restaurant_menu,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Error message
            if (vm.errorCode != null || vm.errorDetails != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vm.errorCode == ShoppingErrorCode.requiredFields
                      ? l10n.shoppingFormRequiredError
                      : vm.errorCode == ShoppingErrorCode.saveError
                          ? l10n.shoppingSaveError
                          : vm.errorDetails ?? '',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Save button
            PrimaryButton(
              text: isEdit ? l10n.shoppingEditItemButton : l10n.shoppingAddItemButton,
              isLoading: vm.loading,
              onPressed: () async {
                final success = await vm.save();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? l10n.shoppingItemUpdated
                            : l10n.shoppingItemAdded,
                      ),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    // Mapa de valores internos a claves de traducción
    final categories = {
      'Frutas y Verduras': l10n.shoppingCategoryFruits,
      'Carnes y Pescados': l10n.shoppingCategoryMeat,
      'Lácteos': l10n.shoppingCategoryDairy,
      'Panadería': l10n.shoppingCategoryBakery,
      'Bebidas': l10n.shoppingCategoryBeverages,
      'Snacks': l10n.shoppingCategorySnacks,
      'Otros': l10n.shoppingCategoryOthers,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: colorScheme.surfaceContainerHighest,
          items: categories.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key, // Valor interno que se guarda en Firestore
              child: Text(
                entry.value, // Texto traducido que se muestra
                style: TextStyle(color: colorScheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}