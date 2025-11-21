import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/theme/colors.dart';
import 'package:smartmeal/presentation/widgets/branding/animated_logo.dart';

class SplashView extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final bool showProgress;

  const SplashView({
    super.key,
    this.error,
    this.onRetry,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedLogo(height: _logoHeight(context)),
            const SizedBox(height: 24),
            if (hasError)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  const Text(
                    'Error inicializando',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
                ],
              )
            else if (showProgress)
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                backgroundColor: AppColors.accent3,
              ),
          ],
        ),
      ),
    );
  }

  double _logoHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return (h * 0.24).clamp(140.0, 260.0).toDouble(); // 24% del alto, límites
  }
}