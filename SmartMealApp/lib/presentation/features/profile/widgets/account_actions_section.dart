import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Sección de acciones de cuenta (cambiar contraseña, cerrar sesión, eliminar).
///
/// Responsabilidades:
/// - Botones para acciones de cuenta
/// - Cambiar contraseña
/// - Cerrar sesión
/// - Eliminar cuenta
///
/// Acciones:
/// 1. **Cambiar contraseña**:
///    - Icon: lock_outline
///    - onChangePassword callback
///    - Navega a flujo de cambio de contraseña
///
/// 2. **Cerrar sesión**:
///    - Icon: logout
///    - onSignOut callback
///    - Sign out de Firebase Auth
///    - Navega a LoginView
///
/// 3. **Eliminar cuenta**:
///    - Icon: delete_outline
///    - onDeleteAccount callback
///    - Acción destructiva (isDestructive: true)
///    - Color rojo para alertar
///    - Requiere confirmación adicional
///
/// Diseño visual:
/// - **Background**: surfaceContainerHighest (dark) o tertiary (light)
/// - **BorderRadius**: 16px
/// - **Padding**: 16px
/// - **Título**: "Cuenta", primary color, bold
///
/// _ActionButton:
/// - InkWell con ripple effect
/// - Row: icon + label
/// - Icon en CircleAvatar (radius 20)
/// - Background normal: primary con alpha 0.12
/// - Background destructivo: error con alpha 0.12
/// - Label: onSurface (normal) o error (destructivo)
///
/// Layout:
/// - Columna vertical
/// - Título arriba
/// - Tres _ActionButton con spacing 8px
///
/// Botones destructivos:
/// - isDestructive: true
/// - Color error para icon y texto
/// - Alerta visual clara
///
/// Callbacks:
/// - Todos opcionales (VoidCallback?)
/// - Si null: botón deshabilitado
///
/// Parámetros:
/// [onChangePassword] - Callback para cambiar contraseña
/// [onSignOut] - Callback para cerrar sesión
/// [onDeleteAccount] - Callback para eliminar cuenta
///
/// Uso:
/// ```dart
/// AccountActionsSection(
///   onChangePassword: () => navigateToChangePassword(),
///   onSignOut: () => signOut(),
///   onDeleteAccount: () => showDeleteConfirmation(),
/// )
/// ```
class AccountActionsSection extends StatelessWidget {
  final VoidCallback? onChangePassword;
  final VoidCallback? onSignOut;
  final VoidCallback? onDeleteAccount;

  const AccountActionsSection({
    super.key,
    this.onChangePassword,
    this.onSignOut,
    this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileAccountSection,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: l10n.profileChangePasswordButton,
            icon: Icons.lock_outline,
            onTap: onChangePassword,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            label: l10n.profileSignOutButton,
            icon: Icons.logout,
            onTap: onSignOut,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            label: l10n.profileDeleteAccountButton,
            icon: Icons.delete_outline,
            isDestructive: true,
            onTap: onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: isDestructive
              ? Border.all(color: colorScheme.error, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
