import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Contenido de la política de privacidad.
///
/// Responsabilidades:
/// - Mostrar política de privacidad completa
/// - 6 secciones con títulos y cuerpos
/// - Fecha de última actualización
/// - Localizado (es/en)
///
/// Secciones:
/// 1. Introducción (qué datos recopilamos)
/// 2. Uso de datos (para qué los usamos)
/// 3. Compartir datos (con quién se comparten)
/// 4. Seguridad (cómo protegemos los datos)
/// 5. Derechos del usuario (acceso, modificación, eliminación)
/// 6. Contacto (cómo contactarnos)
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
///
/// Layout:
/// - Columna vertical
/// - Heading principal
/// - Fecha de actualización
/// - 6 bloques: título + cuerpo
/// - Spacing: 12px entre bloques, 16px después de fecha
///
/// Localización:
/// - Todos los textos desde l10n:
///   * privacyHeading, privacyUpdated
///   * privacySection1Title a privacySection6Title
///   * privacySection1Body a privacySection6Body
///
/// Usado en:
/// - PrivacyPolicyView: scrollable content
///
/// Parámetros:
/// [languageCode] - Código de idioma para formateo de fecha
///
/// Uso:
/// ```dart
/// PrivacyContent(languageCode: 'es')
/// ```
class PrivacyContent extends StatelessWidget {
  const PrivacyContent({super.key, required this.languageCode});

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
        _SectionTitle(l10n.privacyHeading),
        const SizedBox(height: 8),
        Text(l10n.privacyUpdated(lastUpdated)),
        const SizedBox(height: 16),
        _SectionTitle(l10n.privacySection1Title),
        Text(l10n.privacySection1Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.privacySection2Title),
        Text(l10n.privacySection2Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.privacySection3Title),
        Text(l10n.privacySection3Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.privacySection4Title),
        Text(l10n.privacySection4Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.privacySection5Title),
        Text(l10n.privacySection5Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.privacySection6Title),
        Text(l10n.privacySection6Body),
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
