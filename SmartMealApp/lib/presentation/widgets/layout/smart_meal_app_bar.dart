import 'package:flutter/material.dart';

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
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 8.0), // Padding asimétrico
        child: leading ?? _DefaultAvatar(colorScheme: colorScheme),
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
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
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
    return AspectRatio(
      aspectRatio: 1.0, // Fuerza proporción 1:1 (circular perfecto)
      child: Container(
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
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
    return center ? Center(child: column) : column;
  }
}