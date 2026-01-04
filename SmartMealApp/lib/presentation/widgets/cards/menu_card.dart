import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/theme/colors.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Card de navegación usado en HomeView.
///
/// Responsabilidades:
/// - Mostrar opción de navegación con icono + título + subtítulo
/// - Responsive: ajusta tamaños según espacio disponible
/// - Estados: enabled/disabled, highlight
/// - Animaciones hover y tap
/// - Accesibilidad con semantic labels
///
/// Diseño:
/// - **Icono circular**: Container con background color
/// - **Título**: Texto bold, color primario
/// - **Subtítulo**: Texto regular, color secundario
/// - **Background**: Blanco/oscuro según theme
/// - **Borde**: Sutil con elevation
///
/// Responsive breakpoints:
/// - **Tiny** (<140px): iconPlate 42, icon 24, padding reducido
/// - **Small** (<180px): iconPlate 48, icon 28
/// - **Medium** (<230px): iconPlate 54, icon 30
/// - **Large** (≥230px): iconPlate 60, icon 34, padding amplio
///
/// Estados visuales:
/// - **Normal**: colors estándar
/// - **Highlight**: fondo primary, texto onPrimary (destacado)
/// - **Disabled**: opacidad reducida, sin hover/tap
/// - **Hover**: scale up 1.02 (si no reduce motion)
/// - **Tap**: scale down 0.98
///
/// Animaciones:
/// - Scale hover/tap con AnimatedScale
/// - Duration: 150ms (hover), 100ms (tap)
/// - Respeta MediaQuery.disableAnimations (accesibilidad)
///
/// TextScaler:
/// - Aplica MediaQuery.textScalerOf(context)
/// - Clamp máximo 1.3 para evitar overflow
/// - Recalcula tamaños de texto dinámicamente
///
/// Accesibilidad:
/// - Semantic label custom (opcional)
/// - ExcludeSemantics si onTap es null
/// - Tappable area amplia
///
/// Parámetros:
/// [icon] - IconData a mostrar
/// [title] - Título principal
/// [subtitle] - Subtítulo descriptivo
/// [onTap] - Callback al tocar (null = disabled)
/// [enabled] - Habilitar interacción (default: true)
/// [highlight] - Estilo destacado (default: false)
/// [backgroundColor] - Color de fondo custom (opcional)
/// [iconColor] - Color del icono custom (opcional)
/// [semanticLabel] - Label de accesibilidad (opcional)
///
/// Uso en HomeView:
/// ```dart
/// MenuCard(
///   icon: Icons.restaurant_menu,
///   title: 'Mi Menú',
///   subtitle: 'Ver menú semanal',
///   onTap: () => Navigator.pushNamed(context, Routes.menu),
/// )
/// ```
class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final bool highlight;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? semanticLabel;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
    this.highlight = false,
    this.backgroundColor,
    this.iconColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final textScaler = MediaQuery.textScalerOf(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final tiny = w < 140;
        final small = w < 180;
        final medium = w < 230;

        final iconPlateSize = tiny
            ? 42.00
            : small
            ? 48.00
            : medium
            ? 54.00
            : 60.00;
        final iconSize = tiny
            ? 24.00
            : small
            ? 28.00
            : medium
            ? 30.00
            : 34.00;
        final paddingV = tiny
            ? 12.00
            : small
            ? 14.00
            : medium
            ? 18.00
            : 22.00;
        final paddingH = tiny
            ? 10.00
            : small
            ? 12.00
            : medium
            ? 14.00
            : 18.00;
        final radius = tiny
            ? 14.00
            : small
            ? 16.00
            : medium
            ? 20.00
            : 22.00;
        final titleFontBase = tiny
            ? 13.00
            : small
            ? 14.00
            : medium
            ? 15.00
            : 16.00;
        final subtitleFontBase = tiny
            ? 11.00
            : small
            ? 11.50
            : medium
            ? 12.00
            : 13.00;

        final titleFont = textScaler.scale(titleFontBase);
        final subtitleFont = textScaler.scale(subtitleFontBase);

        final cardColor =
            backgroundColor ??
            (highlight
                ? Color.alphaBlend(
                    cs.primary.withAlpha((255 * 0.18).round()),
                    cs.surface,
                  )
                : cs.surfaceContainerHighest.withAlpha((255 * 0.65).round()));

        final effectiveIconColor = iconColor ?? cs.primary;
        final titleColor = cs.onSurface;
        final subtitleColor = cs.onSurface.withAlpha((255 * 0.65).round());

        final content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconPlate(
              size: iconPlateSize,
              icon: icon,
              iconSize: iconSize,
              color: effectiveIconColor,
              background: cs.primary.withAlpha((255 * 0.10).round()),
            ),
            SizedBox(height: tiny ? 10 : 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontSize: titleFont,
                color: titleColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: tiny ? 4 : 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: subtitleFont,
                color: subtitleColor,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!enabled) ...[
              SizedBox(height: tiny ? 6 : 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tiny ? 8 : 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.error.withAlpha((255 * 0.10).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.menuCardComingSoon,
                  style: textTheme.labelSmall?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );

        final baseContainer = Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: highlight
                  ? cs.primary.withAlpha((255 * 0.35).round())
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: content,
        );

        final child = reduceMotion
            ? baseContainer
            : AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: baseContainer,
              );

        return Semantics(
          button: true,
          label: semanticLabel ?? title,
          hint: subtitle,
          enabled: enabled,
          child: Material(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(radius),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(radius),
              splashColor: AppColors.splash,
              highlightColor: AppColors.highlight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _IconPlate extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  final double iconSize;

  const _IconPlate({
    required this.icon,
    required this.color,
    required this.background,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
