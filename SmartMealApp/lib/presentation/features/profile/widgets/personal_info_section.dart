import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Sección que muestra información personal del usuario.
///
/// Responsabilidades:
/// - Mostrar datos personales del perfil
/// - Email, teléfono, edad, género
/// - Altura, peso, BMI
/// - Iconos temáticos por campo
///
/// Campos mostrados:
/// 1. **Email** (obligatorio): email.value
/// 2. **Teléfono** (opcional): phone.formatted
/// 3. **Edad** (opcional): age + "años"
/// 4. **Género** (opcional): localizado (Masculino/Femenino/Otro)
/// 5. **Altura**: height.formatted (ej: "175 cm")
/// 6. **Peso**: weight.formatted (ej: "70 kg")
/// 7. **BMI**: bmi.formatted (ej: "22.9")
///
/// Iconos:
/// - Email: email_outlined
/// - Teléfono: phone_outlined
/// - Edad: cake_outlined
/// - Género: person_outline
/// - Altura: height
/// - Peso: monitor_weight_outlined
/// - BMI: analytics_outlined
///
/// Diseño visual:
/// - **Background**: surfaceContainerHighest (dark) o tertiary (light)
/// - **BorderRadius**: 16px
/// - **Padding**: 16px
/// - **Título**: primary color, bold, 16px
///
/// Layout:
/// - Columna vertical
/// - Título: "Información Personal"
/// - _InfoRow por cada campo (label + value + icon)
/// - Spacing: 12px entre rows
///
/// _InfoRow:
/// - Row con icon + columna de texto
/// - Icon en CircleAvatar (radius 20)
/// - Label en onSurface con alpha 0.6
/// - Value en onSurface, fontSize 14
///
/// Campos opcionales:
/// - Si phone == null: no muestra row
/// - Si age == null: no muestra row
/// - Si gender == null: no muestra row
/// - Otros campos siempre presentes
///
/// Género localizado:
/// - Male: l10n.genderMale
/// - Female: l10n.genderFemale
/// - Other: l10n.genderOther
///
/// Parámetros:
/// [profile] - UserProfile con toda la información
///
/// Uso:
/// ```dart
/// PersonalInfoSection(profile: userProfile)
/// ```
class PersonalInfoSection extends StatelessWidget {
  final UserProfile profile;

  const PersonalInfoSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.tertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profilePersonalInfoSection,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: l10n.profileEmailLabel,
            value: profile.email.value,
            icon: Icons.email_outlined,
          ),
          if (profile.phone != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: l10n.profilePhoneLabel,
              value: profile.phone!.formatted,
              icon: Icons.phone_outlined,
            ),
          ],
          if (profile.age != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: l10n.profileAgeLabel,
              value: '${profile.age} ${l10n.profileYearsOld}',
              icon: Icons.cake_outlined,
            ),
          ],
          if (profile.gender != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: l10n.profileGenderLabel,
              value: _getLocalizedGender(context, profile.gender!),
              icon: Icons.person_outline,
            ),
          ],
          const SizedBox(height: 12),
          _InfoRow(
            label: l10n.profileHeightLabel,
            value: profile.height.formatted,
            icon: Icons.height,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: l10n.profileWeightLabel,
            value: profile.weight.formatted,
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: l10n.profileBmiLabel,
            value:
                '${profile.bmi.toStringAsFixed(1)} - ${_getLocalizedBmiCategory(context, profile.bmiCategory)}',
            icon: Icons.health_and_safety_outlined,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _getLocalizedBmiCategory(BuildContext context, String category) {
  final l10n = context.l10n;
  // El bmiCategory viene en español desde el dominio
  switch (category) {
    case 'Bajo peso':
      return l10n.profileBmiUnderweight;
    case 'Peso normal':
      return l10n.profileBmiNormal;
    case 'Sobrepeso':
      return l10n.profileBmiOverweight;
    case 'Obesidad':
      return l10n.profileBmiObese;
    default:
      return category;
  }
}

String _getLocalizedGender(BuildContext context, Gender gender) {
  final l10n = context.l10n;
  // Usar .value para obtener el string del Gender
  switch (gender.value.toLowerCase()) {
    case 'male':
    case 'masculino':
    case 'm':
      return l10n.profileGenderMale;
    case 'female':
    case 'femenino':
    case 'f':
      return l10n.profileGenderFemale;
    case 'other':
    case 'otro':
      return l10n.profileGenderOther;
    default:
      return gender.value;
  }
}
