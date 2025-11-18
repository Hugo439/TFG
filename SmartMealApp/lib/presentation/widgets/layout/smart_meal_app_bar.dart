import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/theme/colors.dart';

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
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      centerTitle: centerTitle,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: leading ?? _DefaultAvatar(initial: title.isNotEmpty ? title[0] : 'S'),
      ),
      title: _TitleBlock(title: title, subtitle: subtitle, center: centerTitle),
      actions: actions ?? _defaultActions(),
    );
  }

  List<Widget> _defaultActions() {
    if (!showNotification) return const [];
    return [
      IconButton(
        tooltip: 'Notificaciones',
        onPressed: onNotification,
        icon: const Icon(Icons.notifications_none, color: AppColors.primaryText),
        splashColor: AppColors.splash,
        highlightColor: AppColors.highlight,
      ),
    ];
  }
}

class _DefaultAvatar extends StatelessWidget {
  final String initial;
  const _DefaultAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
            style: const TextStyle(
            color: AppColors.alternate,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
  const _TitleBlock({
    required this.title,
    required this.subtitle,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
    return center ? Center(child: column) : column;
  }
}