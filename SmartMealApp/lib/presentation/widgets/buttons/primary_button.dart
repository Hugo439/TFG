import 'package:flutter/material.dart';

/// Botón primario reutilizable de la app.
///
/// Responsabilidades:
/// - Botón principal con estilo consistente
/// - Estado de carga con indicador circular
/// - Deshabilitar automáticamente durante carga
///
/// Características:
/// - **Altura fija**: 48px
/// - **Ancho**: full width (SizedBox sin width)
/// - **Color**: primary del theme (background)
/// - **Color texto**: onPrimary del theme
/// - **Bordes redondeados**: 12px radius
/// - **Sin elevation**: flat design
///
/// Estados:
/// - **Normal**: texto visible, onPressed activo
/// - **Loading**: CircularProgressIndicator, onPressed null
/// - **Disabled**: opacidad reducida, onPressed null
///
/// Indicador de carga:
/// - CircularProgressIndicator 18x18
/// - Color: onPrimary
/// - Stroke: 2px
/// - Reemplaza el texto durante carga
///
/// Compatibilidad:
/// - Acepta tanto `text` como `label` (legacy)
/// - Acepta tanto `isLoading` como `loading` (legacy)
/// - Prioriza `text` sobre `label`
/// - Prioriza `isLoading` sobre `loading`
///
/// Parámetros:
/// [text] - Texto del botón
/// [label] - Texto del botón (legacy, usar text)
/// [onPressed] - Callback al presionar
/// [isLoading] - Mostrar indicador de carga
/// [loading] - Mostrar indicador de carga (legacy)
///
/// Uso:
/// ```dart
/// PrimaryButton(
///   text: 'Iniciar sesión',
///   onPressed: () => login(),
///   isLoading: viewModel.isLoading,
/// )
/// ```
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
