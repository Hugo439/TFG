import 'package:flutter/material.dart';

class LoginPrompt extends StatelessWidget {
  final VoidCallback? onTap;
  const LoginPrompt({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ', 
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6), 
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          child: const Text('Inicia Sesión'),
        ),
      ],
    );
  }
}