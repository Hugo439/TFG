import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final String assetPath;

  const AppLogo({
    super.key,
    this.height = 84,
    this.assetPath = 'assets/branding/logo.png',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stack) => Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.logoNotFound,
          style: TextStyle(
            color: colorScheme.surface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}