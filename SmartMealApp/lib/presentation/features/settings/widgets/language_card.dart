import 'package:flutter/material.dart';

/// Card para selección de idioma.
///
/// Responsabilidades:
/// - Mostrar bandera del idioma (emoji)
/// - Título del idioma
/// - Descripción breve
/// - Indicador de selección
/// - Tap para cambiar idioma
///
/// Contenido típico:
/// - Español: 🇪🇸 | Español | "Idioma español"
/// - English: 🇬🇧 | English | "English language"
///
/// Estados:
/// - **isSelected**: border más grueso o color destacado
/// - **Normal**: border sutil
///
/// Diseño visual:
/// - Background: surfaceContainerHighest
/// - BorderRadius: 16px
/// - Border: outline con alpha 0.2
/// - Padding: 16px horizontal, 14px vertical
///
/// Layout:
/// - Row: flag + columna de texto + arrow
/// - Flag: emoji 32px
/// - Columna: title + description
/// - Arrow: arrow_forward_ios, 16px, primary
///
/// Título:
/// - fontSize: 16px
/// - fontWeight: w600
/// - color: onSurface
///
/// Descripción:
/// - fontSize: 13px
/// - color: onSurface con alpha 0.6
///
/// Interacción:
/// - GestureDetector con onTap
/// - Cambiar locale en LocaleProvider
/// - Actualiza UI de toda la app
///
/// Usado en:
/// - SettingsView: sección de idioma
/// - Diálogo de selección de idioma
///
/// Parámetros:
/// [flag] - Emoji de bandera (🇪🇸, 🇬🇧)
/// [title] - Nombre del idioma
/// [description] - Descripción breve
/// [onTap] - Callback al seleccionar
/// [colorScheme] - ColorScheme del theme
/// [isSelected] - Si está seleccionado actualmente
///
/// Uso:
/// ```dart
/// LanguageCard(
///   flag: '🇪🇸',
///   title: 'Español',
///   description: 'Idioma español',
///   onTap: () => setLocale('es'),
///   colorScheme: Theme.of(context).colorScheme,
///   isSelected: currentLocale == 'es',
/// )
/// ```
class LanguageCard extends StatelessWidget {
  final String flag;
  final String title;
  final String description;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isSelected;

  const LanguageCard({
    super.key,
    required this.flag,
    required this.title,
    required this.description,
    required this.onTap,
    required this.colorScheme,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorScheme.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
