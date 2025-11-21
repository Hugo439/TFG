import 'package:flutter/material.dart';

class FilledTextField extends StatelessWidget {
  final String? hintText;
  final String? label;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;

  const FilledTextField({
    super.key,
    this.hintText,
    this.label,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  }) : assert(controller == null || initialValue == null,
            'Cannot provide both controller and initialValue');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: enabled 
            ? colorScheme.onSurface 
            : colorScheme.onSurface.withOpacity(0.5),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6), 
          fontSize: 14,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6), 
          fontSize: 14,
        ),
        filled: true,
        fillColor: enabled 
            ? colorScheme.surfaceContainerHighest 
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 14,
        ),
        prefixIcon: prefixIcon == null 
            ? null 
            : Icon(prefixIcon, color: colorScheme.primary, size: 20),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2), 
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.1), 
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}