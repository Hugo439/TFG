import 'package:flutter/material.dart';

/// Prompt para navegar a login desde registro.
///
/// Responsabilidades:
/// - Texto "¿Ya tienes cuenta?"
/// - Botón "Inicia Sesión"
/// - Navegar a LoginView
///
/// Usado en:
/// - RegisterView: al final del formulario
/// - Permite cambiar entre login/registro
///
/// Diseño:
/// - Row centrada horizontal
/// - Texto regular + TextButton
/// - Texto: onSurface con alpha 0.6
/// - Botón: primary color, bold
///
/// Interacción:
/// - onTap callback para navegación
/// - Típicamente pop() para volver a login
///
/// Consistencia:
/// - Mismo estilo que RegisterPrompt
/// - Patrón común en apps de auth
///
/// Parámetros:
/// [onTap] - Callback al tocar botón
///
/// Uso:
/// ```dart
/// LoginPrompt(onTap: () => Navigator.pop(context))
/// ```
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
            color: colorScheme.onSurface.withValues(alpha: 0.6),
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
