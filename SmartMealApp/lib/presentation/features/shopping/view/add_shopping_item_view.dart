import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/add_shopping_item_usecase.dart';
import 'package:smartmeal/presentation/features/shopping/viewmodel/add_shopping_item_view_model.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/presentation/widgets/buttons/primary_button.dart';

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
          isEdit ? 'Editar Producto' : 'Añadir Producto',
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
              'Nombre del Producto',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: 'Ej: Arroz Basmati',
              initialValue: vm.name,
              onChanged: vm.setName,
              prefixIcon: Icons.shopping_cart,
            ),
            const SizedBox(height: 16),

            // Cantidad
            Text(
              'Cantidad',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: 'Ej: 500g, 1kg, 2 unidades',
              initialValue: vm.quantity,
              onChanged: vm.setQuantity,
              prefixIcon: Icons.scale,
            ),
            const SizedBox(height: 16),

            // Precio
            Text(
              'Precio (€)',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: 'Ej: 3.50',
              initialValue: vm.price,
              onChanged: vm.setPrice,
              prefixIcon: Icons.euro,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Categoría
            Text(
              'Categoría',
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
              'Para qué menús (opcional)',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledTextField(
              label: 'Ej: Pollo al curry, Ensalada César',
              initialValue: vm.usedInMenus,
              onChanged: vm.setUsedInMenus,
              prefixIcon: Icons.restaurant_menu,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Error message
            if (vm.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vm.error!,
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Save button
            PrimaryButton(
              text: isEdit ? 'Guardar Cambios' : 'Añadir a la Lista',
              isLoading: vm.loading,
              onPressed: () async {
                final success = await vm.save();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'Producto actualizado'
                            : 'Producto añadido a la lista',
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
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: colorScheme.surfaceContainerHighest,
          items: [
            'Frutas y Verduras',
            'Carnes y Pescados',
            'Lácteos',
            'Panadería',
            'Conservas',
            'Congelados',
            'Bebidas',
            'Otros',
          ].map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => onChanged(v ?? value),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Frutas y Verduras':
        return Icons.apple;
      case 'Carnes y Pescados':
        return Icons.set_meal;
      case 'Lácteos':
        return Icons.water_drop;
      case 'Panadería':
        return Icons.bakery_dining;
      case 'Conservas':
        return Icons.local_dining;
      case 'Congelados':
        return Icons.ac_unit;
      case 'Bebidas':
        return Icons.local_drink;
      default:
        return Icons.shopping_bag;
    }
  }
}