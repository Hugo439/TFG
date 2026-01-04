import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/widgets/branding/logo_box.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Header de la pantalla de login con logo y textos.
///
/// Responsabilidades:
/// - Logo de la app (LogoBox)
/// - Título de bienvenida
/// - Subtítulo descriptivo
///
/// Contenido:
/// - LogoBox con height 160px
/// - Título: "Bienvenido a SmartMeal" (l10n.loginWelcome)
/// - Subtítulo: "Inicia sesión para continuar" (l10n.loginSubtitle)
///
/// Diseño:
/// - Columna vertical centrada
/// - Spacing: 24px entre logo y título, 8px entre título y subtítulo
/// - Título: 28px, bold (w800)
/// - Subtítulo: 14px, regular, alpha 0.6
///
/// Consistencia:
/// - Mismo estilo visual que RegisterHeader
/// - Localización completa
///
/// Uso:
/// ```dart
/// Column(
///   children: [
///     LoginHeader(),
///     SizedBox(height: 32),
///     LoginForm(),
///   ],
/// )
/// ```
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
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
