import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';

/// Header del perfil de usuario con avatar y datos básicos.
///
/// Responsabilidades:
/// - Mostrar avatar circular grande
/// - Nombre completo del usuario
/// - Email del usuario
///
/// Avatar:
/// - **Con foto**: NetworkImage desde photoUrl
/// - **Sin foto**: CircleAvatar con inicial del nombre
/// - **Tamaño**: radius 50 (100px diámetro)
/// - **Color**: primary del theme
///
/// Inicial del nombre:
/// - Extrae primera letra del displayName
/// - fontSize 40, bold
/// - Color: onPrimary para contraste
/// - Extensión: profile.displayName.firstLetter
///
/// Nombre:
/// - fontSize 24, bold
/// - Color: onSurface
/// - Value object: displayName.value
///
/// Email:
/// - fontSize 14, regular
/// - Color: onSurface con alpha 0.6
/// - Value object: email.value
///
/// Layout:
/// - Columna vertical centrada
/// - Avatar arriba
/// - Spacing 12px entre avatar y nombre
/// - Spacing 4px entre nombre y email
///
/// Usado en:
/// - ProfileView: visualización del perfil
/// - EditProfileView: preview mientras edita
///
/// Parámetros:
/// [profile] - UserProfile con datos del usuario
///
/// Uso:
/// ```dart
/// ProfileHeader(profile: userProfile)
/// ```
class ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: colorScheme.primary,
          backgroundImage: profile.photoUrl != null
              ? NetworkImage(profile.photoUrl!)
              : null,
          child: profile.photoUrl == null
              ? Text(
                  profile.displayName.firstLetter,
                  style: TextStyle(
                    fontSize: 40,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName.value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email.value,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
