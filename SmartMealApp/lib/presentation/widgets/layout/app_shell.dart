import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/widgets/navigation/bottom_nav_bar.dart';
import 'package:smartmeal/presentation/widgets/layout/smart_meal_app_bar.dart';

class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 1000 ? 48.0 : width > 800 ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SmartMealAppBar(
        title: title,
        subtitle: subtitle,
        centerTitle: centerTitle,
        showNotification: showNotification,
        onNotification: onNotifications,
        leading: leading,
        actions: actions,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 16),
        child: body,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: onNavChange,
      ),
    );
  }
}