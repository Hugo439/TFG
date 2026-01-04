import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/routes/routes.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Prompt para navegar a registro desde login.
///
/// Responsabilidades:
/// - Texto "¿No tienes cuenta?"
/// - Botón "Regístrate"
/// - Navegar a RegisterView
///
/// Usado en:
/// - LoginView: al final del formulario
/// - Permite crear nueva cuenta
///
/// Diseño:
/// - Row centrada horizontal
/// - Texto regular + TextButton
/// - Texto: onSurface con alpha 0.6, 14px
/// - Botón: primary color, bold (w600)
///
/// Navegación:
/// - pushNamed(Routes.register)
/// - No reemplaza stack (permite volver con pop)
///
/// Localización:
/// - Texto: l10n.loginNoAccount
/// - Botón: l10n.loginRegisterLink
///
/// Consistencia:
/// - Mismo estilo que LoginPrompt
/// - Patrón estándar de auth flows
///
/// Uso:
/// ```dart
/// RegisterPrompt()
/// ```
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
            color: colorScheme.onSurface.withValues(alpha: 0.6),
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
