import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String? text;
  final String? label; // Para compatibilidad hacia atrás
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool loading; // Para compatibilidad hacia atrás

  const PrimaryButton({
    super.key,
    this.text,
    this.label,
    this.onPressed,
    this.isLoading = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = text ?? label ?? '';
    final isButtonLoading = isLoading || loading;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isButtonLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: isButtonLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(displayText),
      ),
    );
  }
}