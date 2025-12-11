import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';
import 'package:smartmeal/presentation/features/shopping/widgets/edit_price_dialog.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final ValueChanged<bool?>? onCheckChanged;
  final VoidCallback? onTap;
  final VoidCallback? onPriceEdited;

  const ShoppingItemCard({
    super.key,
    required this.item,
    this.onCheckChanged,
    this.onTap,
    this.onPriceEdited,
  });

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = context.l10n;
    // Las categorías se guardan en español en Firestore
    switch (category) {
      case 'Frutas y Verduras':
        return l10n.shoppingCategoryFruits;
      case 'Carnes y Pescados':
        return l10n.shoppingCategoryMeat;
      case 'Lácteos':
        return l10n.shoppingCategoryDairy;
      case 'Panadería':
        return l10n.shoppingCategoryBakery;
      case 'Bebidas':
        return l10n.shoppingCategoryBeverages;
      case 'Snacks':
        return l10n.shoppingCategorySnacks;
      case 'Otros':
        return l10n.shoppingCategoryOthers;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isChecked
              ? colorScheme.primary.withOpacity(0.1)
              : (colorScheme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
          border: item.isChecked
              ? Border.all(color: colorScheme.primary, width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Checkbox
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: item.isChecked,
                onChanged: onCheckChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.name.value} (${item.quantity.value})',
                    style: TextStyle(
                      color: item.isChecked
                          ? colorScheme.onSurface.withOpacity(0.6)
                          : colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (item.usedInMenus.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.shoppingFor}: ${item.usedInMenus.join(", ")}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Price and Category
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      item.price.formatted,
                      style: TextStyle(
                        color: item.isChecked
                            ? colorScheme.onSurface.withOpacity(0.6)
                            : colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditPriceDialog(
                            item: item,
                            onPriceSaved: onPriceEdited,
                          ),
                        );
                      },
                      tooltip: l10n.shoppingEditPriceTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getLocalizedCategory(context, item.category),
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}