import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/theme/colors.dart';

class LogoBox extends StatelessWidget {
  final double height;
  final Widget? child;

  const LogoBox({super.key, this.height = 84, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryText.withAlpha((255 * 0.90).round()),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: child ??
          const Text(
            '2024',
            style: TextStyle(color: AppColors.alternate, fontSize: 28, fontWeight: FontWeight.w700),
          ),
    );
  }
}