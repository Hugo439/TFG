import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/theme/colors.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

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
