import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Enlaces de contacto directo (email y WhatsApp).
///
/// Responsabilidades:
/// - Botón para abrir cliente de email
/// - Botón para abrir WhatsApp
/// - Lanzar intents externos con url_launcher
///
/// Email:
/// - Uri scheme: mailto
/// - Path: dirección de email
/// - Query: subject=Soporte SmartMeal
/// - Abre cliente de email predeterminado
///
/// WhatsApp:
/// - Uri: https://wa.me/{phone}
/// - Query: ?text=Hola, necesito soporte SmartMeal
/// - LaunchMode: externalApplication
/// - Abre WhatsApp si está instalado
///
/// Manejo de errores:
/// - try/catch en cada launcher
/// - debugPrint si falla
/// - No muestra error al usuario (silencioso)
///
/// Layout:
/// - Row horizontal con dos botones
/// - Spacing: 16px entre botones
/// - ElevatedButton.icon con icono + label
///
/// Botones:
/// - **Email**: icon email, primary color
/// - **WhatsApp**: icon message (o whatsapp custom), secondary color
///
/// Localización:
/// - Labels: l10n.contactEmail, l10n.contactWhatsApp
///
/// Dependencias:
/// - url_launcher package
/// - Permisos en AndroidManifest/Info.plist
///
/// Parámetros:
/// [email] - Dirección de email de soporte
/// [whatsapp] - Número de WhatsApp (formato internacional sin +)
///
/// Uso:
/// ```dart
/// ContactLinks(
///   email: 'soporte@smartmeal.com',
///   whatsapp: '34612345678',
/// )
/// ```
class ContactLinks extends StatelessWidget {
  final String email;
  final String whatsapp;

  const ContactLinks({super.key, required this.email, required this.whatsapp});

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Soporte SmartMeal',
    );

    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        debugPrint('No se pudo abrir el cliente de email');
      }
    } catch (e) {
      debugPrint('Error al abrir email: $e');
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/$whatsapp?text=Hola,%20necesito%20soporte%20SmartMeal',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('No se pudo abrir WhatsApp');
      }
    } catch (e) {
      debugPrint('Error al abrir WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.email),
          label: Text(context.l10n.contactEmail),
          onPressed: _launchEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.chat),
          label: Text(context.l10n.contactWhatsApp),
          onPressed: _launchWhatsApp,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
