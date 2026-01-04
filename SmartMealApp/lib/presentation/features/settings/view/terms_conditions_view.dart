import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/features/settings/widgets/terms_content.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Pantalla de términos y condiciones.
///
/// Responsabilidades:
/// - Mostrar texto legal de los términos y condiciones
/// - Contenido localizado (es/en)
/// - Scroll vertical para lectura completa
///
/// Contenido (TermsContent):
/// - Aceptación de términos
/// - Descripción del servicio
/// - Cuenta de usuario (creación, responsabilidades)
/// - Uso aceptable de la app
/// - Propiedad intelectual
/// - Limitación de responsabilidad
/// - Modificaciones de los términos
/// - Terminación de cuenta
/// - Ley aplicable
/// - Contacto
///
/// Localización:
/// - TermsContent recibe languageCode (es/en)
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
/// Navigator.pushNamed(context, Routes.termsConditions);
/// ```
class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsHeading),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: TextStyle(color: colorScheme.onSurface, height: 1.4),
            child: TermsContent(languageCode: lang),
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}
