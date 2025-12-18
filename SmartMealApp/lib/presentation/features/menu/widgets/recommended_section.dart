import 'package:flutter/material.dart';

class RecommendedSection extends StatelessWidget {
  final int menuCount;
  final VoidCallback? onInfoTap;

  const RecommendedSection({
    super.key,
    required this.menuCount,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.restaurant_menu, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Menús Recomendados',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '$menuCount menús',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        if (onInfoTap != null) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: onInfoTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }
}
