import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Header de la pantalla de registro.
///
/// Responsabilidades:
/// - Título "Crear Cuenta"
/// - Subtítulo descriptivo
///
/// Contenido:
/// - Título: l10n.registerHeader
/// - Subtítulo: l10n.registerSubtitle ("Completa tus datos")
///
/// Diseño:
/// - Columna vertical
/// - Título: 28px, bold (w800)
/// - Subtítulo: 14px, regular, alpha 0.6
/// - Spacing: 8px entre título y subtítulo
///
/// Diferencia con LoginHeader:
/// - No muestra LogoBox (ya se vió en login)
/// - Más compacto
/// - Enfocado en acción de registro
///
/// Uso:
/// ```dart
/// Column(
///   children: [
///     RegisterHeader(),
///     SizedBox(height: 24),
///     RegisterForm(),
///   ],
/// )
/// ```
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
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
