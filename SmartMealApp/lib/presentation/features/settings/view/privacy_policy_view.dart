import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/features/settings/widgets/privacy_content.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Pantalla de política de privacidad.
///
/// Responsabilidades:
/// - Mostrar texto legal de la política de privacidad
/// - Contenido localizado (es/en)
/// - Scroll vertical para lectura completa
///
/// Contenido (PrivacyContent):
/// - Información recopilada (datos personales, uso)
/// - Cómo se usa la información
/// - Compartir datos con terceros
/// - Seguridad de los datos
/// - Derechos del usuario
/// - Cambios en la política
/// - Contacto
///
/// Localización:
/// - PrivacyContent recibe languageCode (es/en)
/// - Muestra texto en idioma correspondiente
/// - Cargado desde widget separado para facilitar edición
///
/// Layout:
/// - AppBar con título localizado
/// - SingleChildScrollView para texto largo
/// - Padding 16px
/// - DefaultTextStyle para consistencia visual
///
/// Navegación:
/// - Acceso desde SettingsView (sección Legal)
/// - Botón volver a Settings
///
/// Uso:
/// ```dart
/// Navigator.pushNamed(context, Routes.privacyPolicy);
/// ```
class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyHeading),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: TextStyle(color: colorScheme.onSurface, height: 1.4),
            child: PrivacyContent(languageCode: lang),
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}
