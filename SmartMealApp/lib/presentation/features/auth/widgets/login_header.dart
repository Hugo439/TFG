import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/widgets/branding/logo_box.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    return Column(
      children: [
        const LogoBox(height: 160),
        const SizedBox(height: 24),
        Text(
          l10n.loginWelcome,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.loginSubtitle,
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