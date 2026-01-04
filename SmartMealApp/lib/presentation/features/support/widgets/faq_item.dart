import 'package:flutter/material.dart';

/// Item individual de FAQ (pregunta y respuesta).
///
/// Responsabilidades:
/// - Mostrar pregunta destacada
/// - Mostrar respuesta debajo
/// - Icono de ayuda para identificación rápida
///
/// Diseño visual:
/// - **Background**: surfaceContainerHighest
/// - **BorderRadius**: 12px
/// - **Border**: outline con alpha 0.2
/// - **Margin**: 12px bottom (separación entre items)
/// - **Padding**: 16px
///
/// Layout:
/// - Columna vertical
/// - Row arriba: icon + pregunta
/// - Respuesta debajo con padding left 28px (alineada con texto)
///
/// Pregunta:
/// - Icon: help_outline, primary color, 20px
/// - Texto: bold, 15px, primary color
/// - Expanded para wrap text
///
/// Respuesta:
/// - fontSize: 14px
/// - color: onSurface con alpha 0.8
/// - height: 1.4 (line height)
/// - Indent left para alineación visual
///
/// Estados:
/// - No expandible (diferencia con ExpansionTile)
/// - Siempre muestra respuesta completa
/// - Diseño simple y directo
///
/// Usado en:
/// - FAQList: renderiza colección de estos items
/// - SupportView: sección de ayuda
///
/// Parámetros:
/// [question] - Texto de la pregunta
/// [answer] - Texto de la respuesta
///
/// Uso:
/// ```dart
/// FAQItem(
///   question: '¿Cómo genero un menú?',
///   answer: 'Ve a la pestaña Menús y toca "Generar menú"...',
/// )
/// ```
class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
