import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    return Column(
      children: [
        Text(
          l10n.registerHeader,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.registerSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}