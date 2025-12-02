import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartmeal/presentation/widgets/navigation/bottom_nav_bar.dart';
import 'package:smartmeal/presentation/widgets/layout/smart_meal_app_bar.dart';

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
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final title = message.notification?.title ?? '¡SmartMeal!';
      final body = message.notification?.body ?? 'Tienes una nueva notificación';

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
            label: 'Ver',
            textColor: colorScheme.primary,
            onPressed: () {
              // Ejemplo: navega a la pantalla de soporte
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
    final horizontal = width > 1000 ? 48.0 : width > 800 ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SmartMealAppBar(
        title: widget.title,
        subtitle: widget.subtitle,
        centerTitle: widget.centerTitle,
        showNotification: widget.showNotification,
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