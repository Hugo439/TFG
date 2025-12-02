import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/routes/routes.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class RegisterPrompt extends StatelessWidget {
  const RegisterPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.loginNoAccount, 
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6), 
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.register),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          child: Text(l10n.loginRegisterLink),
        ),
      ],
    );
  }
}

