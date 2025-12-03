import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class RetryError extends StatelessWidget {
  final String? title;
  final String details;
  final VoidCallback? onRetry;

  const RetryError({
    super.key,
    this.title,
    required this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
        const SizedBox(height: 12),
        Text(
          title ?? l10n.errorTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          child: Text(l10n.errorRetry),
        ),
      ],
    );
  }
}