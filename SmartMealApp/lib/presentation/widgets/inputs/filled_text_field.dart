import 'package:flutter/material.dart';

/// Campo de texto con estilo filled (relleno).
///
/// Responsabilidades:
/// - Input de texto con diseño consistente
/// - Validación integrada con Form
/// - Estados: enabled/disabled
/// - Iconos y sufijos personalizables
///
/// Características visuales:
/// - **Background**: surfaceContainerHighest (relleno)
/// - **Bordes**: outline con alpha 0.2
/// - **Border radius**: 8px
/// - **Label**: flotante, color onSurface con alpha 0.6
/// - **Hint**: color onSurface con alpha 0.6
/// - **Texto**: fontSize 14
///
/// Estados visuales:
/// - **Enabled**: colores normales
/// - **Disabled**: opacidad reducida, background con alpha 0.3
/// - **Focus**: borde primary, label primary
/// - **Error**: borde error, mensaje de error debajo
///
/// Iconos:
/// - **prefixIcon**: icono a la izquierda (color primary, size 20)
/// - **suffix**: widget custom a la derecha (ej: botón visibilidad)
///
/// Validación:
/// - Usa TextFormField para integración con Form
/// - validator retorna String? (null = válido, String = error)
/// - Muestra mensaje de error debajo del campo
///
/// Soporte multiline:
/// - maxLines: 1 por defecto (single line)
/// - maxLines > 1: textarea expandible
/// - Ajusta contentPadding vertical automáticamente
///
/// Controller vs initialValue:
/// - controller: control externo del texto
/// - initialValue: valor inicial sin control externo
/// - Assert: no se pueden usar ambos simultáneamente
///
/// Parámetros:
/// [hintText] - Texto de ayuda (placeholder)
/// [label] - Label flotante
/// [controller] - TextEditingController para control externo
/// [initialValue] - Valor inicial (sin controller)
/// [keyboardType] - Tipo de teclado (text, email, number, etc.)
/// [obscureText] - Ocultar texto (para contraseñas)
/// [prefixIcon] - Icono prefijo
/// [suffix] - Widget sufijo
/// [validator] - Función de validación
/// [onChanged] - Callback al cambiar texto
/// [enabled] - Habilitar input
/// [maxLines] - Número de líneas (1 = single line)
///
/// Uso:
/// ```dart
/// FilledTextField(
///   label: 'Email',
///   hintText: 'usuario@ejemplo.com',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: Icons.email,
///   validator: (value) => validateEmail(value),
/// )
/// ```
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
  }) : assert(
         controller == null || initialValue == null,
         'Cannot provide both controller and initialValue',
       );

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
            : colorScheme.onSurface.withValues(alpha: 0.5),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: enabled
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
            color: colorScheme.outline.withValues(alpha: 0.2),
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
            color: colorScheme.outline.withValues(alpha: 0.1),
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
