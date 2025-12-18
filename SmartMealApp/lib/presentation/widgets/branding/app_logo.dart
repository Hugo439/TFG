import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

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
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n?.logoNotFound ?? 'Logo no encontrado',
          style: TextStyle(color: colorScheme.surface, fontSize: 14),
        ),
      ),
    );
  }
}
