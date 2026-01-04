import 'package:flutter/material.dart';

/// Botón con icono y estado de carga.
///
/// Responsabilidades:
/// - Botón con icono + texto
/// - Estado de carga que reemplaza icono
/// - Colores personalizables
///
/// Características:
/// - **Tamaño**: full width, 48px height
/// - **Tipo**: ElevatedButton.icon (icono + label)
/// - **Bordes redondeados**: 12px radius
/// - **Sin elevation**: flat design
///
/// Estados:
/// - **Normal**: icono + texto, onPressed activo
/// - **Loading**: CircularProgressIndicator + texto, onPressed null
/// - **Disabled**: opacidad reducida, onPressed null
///
/// Indicador de carga:
/// - CircularProgressIndicator 18x18
/// - Reemplaza el icono (no el texto)
/// - Color: foregroundColor (default: onPrimary)
/// - Stroke: 2px
///
/// Colores personalizables:
/// - backgroundColor: primary por defecto
/// - foregroundColor: onPrimary por defecto
/// - Permite temas alternativos (ej: botón secundario)
///
/// Parámetros:
/// [text] - Texto del botón
/// [icon] - IconData a mostrar
/// [onPressed] - Callback al presionar
/// [isLoading] - Mostrar indicador de carga
/// [backgroundColor] - Color de fondo (default: primary)
/// [foregroundColor] - Color de texto/icono (default: onPrimary)
///
/// Uso:
/// ```dart
/// IconLoadingButton(
///   text: 'Generar menú',
///   icon: Icons.auto_awesome,
///   onPressed: () => generate(),
///   isLoading: viewModel.isGenerating,
/// )
/// ```
class IconLoadingButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const IconLoadingButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: foregroundColor ?? colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
