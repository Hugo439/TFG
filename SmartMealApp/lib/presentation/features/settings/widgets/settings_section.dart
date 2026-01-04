import 'package:flutter/material.dart';

/// Agrupador de items de configuración con título.
///
/// Responsabilidades:
/// - Agrupar tiles relacionados
/// - Título de sección
/// - Divisores entre items
/// - Container decorado
///
/// Estructura:
/// - Título arriba (fuera del container)
/// - Container con todos los children
/// - Dividers automáticos entre children
///
/// Título:
/// - fontSize: 14px
/// - fontWeight: w600
/// - color: onSurface con alpha 0.6
/// - letterSpacing: 0.5
/// - padding left: 16px, bottom: 8px
/// - Uppercase implícito por estilo
///
/// Container:
/// - Background: surfaceContainerHighest (dark) o surface (light)
/// - BorderRadius: 12px
/// - BoxShadow: sutil, alpha 0.05
///
/// Dividers:
/// - Insertados automáticamente entre children
/// - height: 1px
/// - indent: 56px (alinea con texto de tiles)
/// - color: onSurface con alpha 0.1
/// - No divider después del último item
///
/// _buildChildrenWithDividers:
/// - Loop por children
/// - Inserta Divider entre cada par
/// - Omite divider final
///
/// Usado en:
/// - SettingsView: agrupa tiles por categoría
/// - Ejemplos: "Cuenta", "Apariencia", "Privacidad"
///
/// Típicos children:
/// - SettingsTile con Switch
/// - SettingsTile con chevron_right
/// - Cualquier widget custom
///
/// Parámetros:
/// [title] - Título de la sección
/// [children] - Lista de widgets (típicamente SettingsTile)
///
/// Uso:
/// ```dart
/// SettingsSection(
///   title: 'APARIENCIA',
///   children: [
///     SettingsTile(
///       icon: Icons.dark_mode,
///       title: 'Modo oscuro',
///       trailing: Switch(...),
///     ),
///     SettingsTile(
///       icon: Icons.language,
///       title: 'Idioma',
///       trailing: Icon(Icons.chevron_right),
///     ),
///   ],
/// )
/// ```
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.brightness == Brightness.dark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: _buildChildrenWithDividers(colorScheme)),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(ColorScheme colorScheme) {
    final widgets = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      if (i < children.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 56,
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        );
      }
    }
    return widgets;
  }
}
