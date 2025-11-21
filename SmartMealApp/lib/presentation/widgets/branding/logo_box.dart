import 'package:flutter/material.dart';

class LogoBox extends StatelessWidget {
  final double height;
  final Widget? child;

  const LogoBox({super.key, this.height = 84, this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child ??
          Image.asset(
            'assets/branding/logo.png',
            height: height * 0.8,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'SmartMeal',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
    );
  }
}