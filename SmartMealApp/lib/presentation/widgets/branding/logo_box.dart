import 'package:flutter/material.dart';

class LogoBox extends StatelessWidget {
  final double height;
  final Widget? child;

  const LogoBox({super.key, this.height = 84, this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child:
          child ??
          Image.asset(
            'assets/branding/logo.png',
            height: height * 0.85,
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
