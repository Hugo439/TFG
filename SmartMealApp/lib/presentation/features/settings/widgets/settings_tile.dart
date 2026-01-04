import 'package:flutter/material.dart';

/// Tile reutilizable para items de configuración.
///
/// Responsabilidades:
/// - Item clickable con icono + título + subtítulo
/// - Trailing widget personalizable (flecha, switch, etc.)
/// - Efecto ripple en tap
///
/// Diseño visual:
/// - **Icono**: Container 40x40 con background color, radius 8px
/// - **Título**: fontSize 16, medium weight
/// - **Subtítulo**: fontSize 13, color reducido (opcional)
/// - **Trailing**: widget custom a la derecha
/// - **Ripple**: InkWell con borderRadius 12px
///
/// Layout:
/// - Row horizontal
/// - Icono en container decorado (izquierda)
/// - Columna con título + subtítulo (centro, expandido)
/// - Trailing widget (derecha)
///
/// Trailing típicos:
/// - Switch: para opciones on/off
/// - Icon(Icons.chevron_right): para navegación
/// - Badge con número
/// - Custom widget
///
/// Color personalizable:
/// - titleColor: override para título e icono
/// - Default: primary para icono, onSurface para título
/// - Útil para items destructivos (rojo)
///
/// Padding:
/// - Horizontal: 16px
/// - Vertical: 12px
/// - Spacing interno: 12px entre elementos
///
/// Usado en:
/// - SettingsView: todas las opciones de configuración
/// - Agrupado en SettingsSection
///
/// Parámetros:
/// [icon] - IconData a mostrar
/// [title] - Título principal
/// [subtitle] - Descripción opcional
/// [trailing] - Widget a la derecha (Switch, Icon, etc.)
/// [onTap] - Callback al tocar
/// [titleColor] - Color custom para título e icono
///
/// Uso:
/// ```dart
/// SettingsTile(
///   icon: Icons.dark_mode,
///   title: 'Modo oscuro',
///   subtitle: 'Cambia el tema de la app',
///   trailing: Switch(
///     value: isDark,
///     onChanged: (v) => toggleTheme(),
///   ),
/// )
/// ```
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: titleColor ?? colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: titleColor ?? colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
