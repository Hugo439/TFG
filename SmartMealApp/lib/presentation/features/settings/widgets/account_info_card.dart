import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';

/// Card con información de cuenta en SettingsView.
///
/// Responsabilidades:
/// - Avatar del usuario
/// - Nombre de usuario
/// - Email
///
/// Diseño visual:
/// - **Gradient**: primary a secondary
/// - **Dirección**: topLeft a bottomRight
/// - **BoxShadow**: primary con alpha 0.3, blur 8
/// - **BorderRadius**: 16px
/// - **Padding**: 16px
///
/// Avatar:
/// - CircleAvatar radius 32
/// - Background: surface
/// - Inicial del nombre en primary
/// - fontSize 28, bold
/// - Fallback: "U" si displayName vacío
///
/// Nombre:
/// - fontSize 18, bold
/// - Color: onPrimary
/// - Fallback: "Usuario" si vacío
///
/// Email:
/// - fontSize 14, regular
/// - Color: onPrimary con alpha 0.9
/// - Value object: profile.emailValue
///
/// Layout:
/// - Row: avatar + columna de texto
/// - Spacing: 16px entre avatar y texto
/// - Columna: nombre + email con spacing 4px
///
/// Usado en:
/// - SettingsView: arriba de todo, destaca info de usuario
///
/// Consistencia:
/// - Mismo gradient que otras cards destacadas
/// - Avatar similar a ProfileHeader
///
/// Parámetros:
/// [profile] - UserProfile con displayName y email
///
/// Uso:
/// ```dart
/// AccountInfoCard(profile: userProfile)
/// ```
class AccountInfoCard extends StatelessWidget {
  final UserProfile profile;

  const AccountInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.surface,
            child: Text(
              profile.displayNameValue.isNotEmpty
                  ? profile.displayNameValue[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayNameValue.isNotEmpty
                      ? profile.displayNameValue
                      : 'Usuario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.emailValue,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
