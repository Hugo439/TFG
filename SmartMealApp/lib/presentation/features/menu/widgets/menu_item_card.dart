import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.brightness == Brightness.dark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.tertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                image: menuItem.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(menuItem.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: menuItem.imageUrl == null
                  ? Icon(
                      Icons.restaurant,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name.value,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuItem.description.value,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // More button
            if (onMoreTap != null)
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: onMoreTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
