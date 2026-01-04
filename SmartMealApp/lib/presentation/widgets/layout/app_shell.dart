import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartmeal/presentation/widgets/navigation/bottom_nav_bar.dart';
import 'package:smartmeal/presentation/widgets/layout/smart_meal_app_bar.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Layout principal que envuelve las pantallas con navegación inferior.
///
/// Responsabilidades:
/// - Proporcionar estructura común (AppBar + Body + BottomNav)
/// - Manejo de notificaciones FCM en primer plano
/// - Navegación consistente entre sección principales
///
/// Componentes:
/// - **SmartMealAppBar**: Barra superior con título, subtítulo, avatar, notificaciones
/// - **Body**: Contenido de la pantalla actual
/// - **BottomNavBar**: Navegación inferior (3 items: Menús, Home, Compras)
///
/// Notificaciones FCM:
/// - Escucha FirebaseMessaging.onMessage en primer plano
/// - Muestra SnackBar flotante con:
///   * Icono de notificación
///   * Título y cuerpo del mensaje
///   * Botón "Ver" que navega a /support
/// - SnackBar visible durante 4 segundos
/// - Diseño personalizado con colorScheme
///
/// Navegación inferior:
/// - 3 items principales:
///   * 0: Menús (MenuView)
///   * 1: Home (HomeView)
///   * 2: Compras (ShoppingView)
/// - selectedIndex indica tab actual
/// - onNavChange callback para cambiar tab
///
/// Parámetros:
/// [title] - Título de la pantalla (AppBar)
/// [subtitle] - Subtítulo descriptivo
/// [selectedIndex] - Índice del tab seleccionado (0-2)
/// [onNavChange] - Callback al cambiar tab
/// [body] - Contenido principal de la pantalla
/// [onNotifications] - Callback del botón notificaciones (opcional)
/// [leading] - Widget custom en leading de AppBar (opcional)
/// [actions] - Acciones adicionales en AppBar (opcional)
/// [centerTitle] - Centrar título en AppBar (default: false)
/// [showNotification] - Mostrar botón notificaciones (default: true)
///
/// Uso:
/// ```dart
/// AppShell(
///   title: 'Mi Menú',
///   subtitle: 'Planificación semanal',
///   selectedIndex: 0,
///   onNavChange: (index) => navigate(index),
///   body: MenuContent(),
/// )
/// ```
class AppShell extends StatefulWidget {
  final String title;
  final String subtitle;
  final int selectedIndex;
  final ValueChanged<int> onNavChange;
  final Widget body;
  final VoidCallback? onNotifications;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showNotification;

  const AppShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedIndex,
    required this.onNavChange,
    required this.body,
    this.onNotifications,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.showNotification = true,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final l10n = context.l10n;

      final title =
          message.notification?.title ?? l10n.notificationDefaultTitle;
      final body = message.notification?.body ?? l10n.notificationDefaultBody;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.notifications_active, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      body,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: l10n.notificationActionView,
            textColor: colorScheme.primary,
            onPressed: () {
              if (!mounted) return;
              Navigator.of(context).pushNamed('/support');
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 1000
        ? 48.0
        : width > 800
        ? 32.0
        : 16.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SmartMealAppBar(
        title: widget.title,
        subtitle: widget.subtitle,
        centerTitle: widget.centerTitle,
        showNotification: false,
        onNotification: widget.onNotifications,
        leading: widget.leading,
        actions: widget.actions,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 16),
        child: widget.body,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onNavChange,
      ),
    );
  }
}
