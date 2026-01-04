import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Contenido de los términos y condiciones.
///
/// Responsabilidades:
/// - Mostrar términos y condiciones completos
/// - 5 secciones con títulos y cuerpos
/// - Fecha de última actualización
/// - Localizado (es/en)
///
/// Secciones:
/// 1. Aceptación de términos (acuerdo de uso)
/// 2. Uso del servicio (reglas y restricciones)
/// 3. Propiedad intelectual (derechos de autor)
/// 4. Limitación de responsabilidad (disclaimers)
/// 5. Cambios a los términos (actualizaciones futuras)
///
/// Fecha de actualización:
/// - Hardcoded: DateTime(2025, 12, 17)
/// - Formateada con DateFormat.yMMMMd
/// - Localizada según languageCode
///
/// _SectionTitle:
/// - Widget helper para títulos
/// - fontSize 18, bold
/// - Color: onSurface
/// - Mismo helper que PrivacyContent
///
/// Layout:
/// - Columna vertical
/// - Heading principal
/// - Fecha de actualización
/// - 5 bloques: título + cuerpo
/// - Spacing: 12px entre bloques, 16px después de fecha
///
/// Localización:
/// - Todos los textos desde l10n:
///   * termsHeading, termsUpdated
///   * termsSection1Title a termsSection5Title
///   * termsSection1Body a termsSection5Body
///
/// Consistencia:
/// - Mismo estilo que PrivacyContent
/// - Estructura similar para UX coherente
///
/// Usado en:
/// - TermsConditionsView: scrollable content
///
/// Parámetros:
/// [languageCode] - Código de idioma para formateo de fecha
///
/// Uso:
/// ```dart
/// TermsContent(languageCode: 'es')
/// ```
class TermsContent extends StatelessWidget {
  const TermsContent({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lastUpdated = DateFormat.yMMMMd(
      languageCode,
    ).format(DateTime(2025, 12, 17));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.termsHeading),
        const SizedBox(height: 8),
        Text(l10n.termsUpdated(lastUpdated)),
        const SizedBox(height: 16),
        _SectionTitle(l10n.termsSection1Title),
        Text(l10n.termsSection1Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection2Title),
        Text(l10n.termsSection2Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection3Title),
        Text(l10n.termsSection3Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection4Title),
        Text(l10n.termsSection4Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection5Title),
        Text(l10n.termsSection5Body),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }
}
