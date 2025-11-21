import 'package:flutter/material.dart';

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
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.tertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Cuenta',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Cambiar Contraseña',
            icon: Icons.lock_outline,
            onTap: onChangePassword,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            label: 'Cerrar Sesión',
            icon: Icons.logout,
            onTap: onSignOut,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            label: 'Eliminar Cuenta',
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
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}