import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final ValueChanged<bool?>? onCheckChanged;
  final VoidCallback? onTap;

  const ShoppingItemCard({
    super.key,
    required this.item,
    this.onCheckChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
                      'Para: ${item.usedInMenus.join(", ")}',
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
                const SizedBox(height: 2),
                Text(
                  item.category,
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