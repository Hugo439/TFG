import 'package:flutter/material.dart';

/// AppBar personalizado de SmartMeal con título, subtítulo y avatar.
///
/// Responsabilidades:
/// - Barra superior con diseño consistente
/// - Título y subtítulo apilados
/// - Avatar circular en leading (o widget custom)
/// - Botón de notificaciones (opcional)
/// - Acciones adicionales personalizables
///
/// Características:
/// - **Altura fija**: 80px (más alto que AppBar estándar)
/// - **Leading**: Avatar circular por defecto, customizable
/// - **Title**: Columna con título + subtítulo
/// - **Actions**: Botón notificaciones por defecto + acciones extra
///
/// Título y subtítulo:
/// - Título: fontSize 20, bold, color onSurface
/// - Subtítulo: fontSize 12, regular, color onSurface con alpha 0.6
/// - Alineación: izquierda por defecto, centrado si centerTitle=true
///
/// Avatar por defecto:
/// - Container circular con iniciales del usuario
/// - Colores del theme (surfaceContainerHigh + onSurface)
/// - Icono person si no hay iniciales
///
/// Botón notificaciones:
/// - Icono notifications_none
/// - onNotification callback opcional
/// - Oculto si showNotification=false
/// - Splash y highlight colors personalizados
///
/// Padding ajustado:
/// - Leading: 12px left, 8px top
/// - Título: 8px top
/// - Acciones: 8px top
/// - Diseño asimétrico para mejor visual
///
/// Parámetros:
/// [title] - Título principal del AppBar
/// [subtitle] - Subtítulo descriptivo
/// [centerTitle] - Centrar título (default: false)
/// [showNotification] - Mostrar botón notificaciones (default: true)
/// [onNotification] - Callback al tocar notificaciones
/// [leading] - Widget custom para leading (default: avatar)
/// [actions] - Acciones adicionales al final del AppBar
///
/// Uso:
/// ```dart
/// SmartMealAppBar(
///   title: 'Menú Semanal',
///   subtitle: '7 días de comidas',
///   onNotification: () => showNotifications(),
/// )
/// ```
class SmartMealAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool centerTitle;
  final bool showNotification;
  final VoidCallback? onNotification;
  final Widget? leading;
  final List<Widget>? actions;

  const SmartMealAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.centerTitle = false,
    this.showNotification = true,
    this.onNotification,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surfaceContainerHighest,
      elevation: 0,
      centerTitle: centerTitle,
      leadingWidth: 64,
      leading: Center(
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.only(left: 8.0),
          child: leading ?? _DefaultAvatar(colorScheme: colorScheme),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0), // Mueve el título hacia abajo
        child: _TitleBlock(
          title: title,
          subtitle: subtitle,
          center: centerTitle,
          colorScheme: colorScheme,
        ),
      ),
      actions: actions ?? _defaultActions(context),
    );
  }

  List<Widget> _defaultActions(BuildContext context) {
    if (!showNotification) return const [];
    final colorScheme = Theme.of(context).colorScheme;
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8.0), // Mueve el icono hacia abajo
        child: IconButton(
          tooltip: 'Notificaciones',
          onPressed: onNotification,
          icon: Icon(Icons.notifications_none, color: colorScheme.onSurface),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        ),
      ),
    ];
  }
}

class _DefaultAvatar extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DefaultAvatar({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/branding/icono.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool center;
  final ColorScheme colorScheme;

  const _TitleBlock({
    required this.title,
    required this.subtitle,
    required this.center,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    return center ? Center(child: column) : column;
  }
}
