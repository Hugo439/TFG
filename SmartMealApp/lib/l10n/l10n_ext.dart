import 'package:flutter/widgets.dart';
import 'package:smartmeal/l10n/app_localizations.dart';

/// Extension para acceso rápido a localizaciones.
///
/// Responsabilidades:
/// - Getter context.l10n para AppLocalizations
/// - Simplifica acceso a traducciones
/// - Evita AppLocalizations.of(context)! repetitivo
///
/// Uso:
/// ```dart
/// // Antes
/// Text(AppLocalizations.of(context)!.loginWelcome)
///
/// // Después
/// Text(context.l10n.loginWelcome)
///
/// // En widgets
/// final l10n = context.l10n;
/// Column(
///   children: [
///     Text(l10n.loginWelcome),
///     Text(l10n.loginSubtitle),
///   ],
/// )
/// ```
///
/// Archivos de localización:
/// - app_es.arb: strings en español
/// - app_en.arb: strings en inglés
/// - Generados: app_localizations.dart, app_localizations_es.dart, app_localizations_en.dart
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
