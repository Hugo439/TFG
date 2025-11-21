import 'package:flutter/material.dart';

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
          'Logo no encontrado',
          style: TextStyle(
            color: colorScheme.surface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}