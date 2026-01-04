import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Sección que muestra objetivos y restricciones alimentarias.
///
/// Responsabilidades:
/// - Mostrar objetivo principal del usuario
/// - Listar alergias e intolerancias
///
/// Contenido:
/// 1. **Objetivo principal**: dropdown con goal actual
/// 2. **Alergias**: lista de chips con alergias del usuario
///
/// Objetivos disponibles:
/// - loseWeight: Perder peso
/// - maintainWeight: Mantener peso
/// - gainMuscle: Ganar músculo
/// - healthyEating: Alimentación saludable
///
/// Alergias:
/// - Lista separada por comas
/// - Mostrada como chips individuales
/// - Color: primary con alpha 0.1
/// - Sin alergias: muestra "Ninguna"
///
/// Diseño visual:
/// - **Background**: surfaceContainerHighest (dark) o tertiary (light)
/// - **BorderRadius**: 16px
/// - **Padding**: 16px
/// - **Título**: "Objetivos y Restricciones", primary color, bold
///
/// _buildDropdown:
/// - Label + container con valor actual
/// - Simula dropdown pero solo lectura
/// - Background: surface
/// - BorderRadius: 8px
/// - Icon chevron_right a la derecha
///
/// _buildAllergies:
/// - Label "Alergias e Intolerancias"
/// - Wrap con chips para cada alergia
/// - Spacing: 8px entre chips
/// - Chip: primary background, small size
///
/// Estados:
/// - Con alergias: muestra lista
/// - Sin alergias: muestra "Ninguna" en texto regular
///
/// Localización:
/// - Título: l10n.profileGoalsSection
/// - Objetivo: l10n.goalLoseWeight, etc.
/// - Alergias: directamente del value object
///
/// Parámetros:
/// [profile] - UserProfile con goal y allergies
///
/// Uso:
/// ```dart
/// GoalsSection(profile: userProfile)
/// ```
class GoalsSection extends StatelessWidget {
  final UserProfile profile;

  const GoalsSection({super.key, required this.profile});

  String _getLocalizedGoal(BuildContext context, GoalType goalType) {
    final l10n = context.l10n;
    switch (goalType) {
      case GoalType.loseWeight:
        return l10n.goalLoseWeight;
      case GoalType.maintainWeight:
        return l10n.goalMaintainWeight;
      case GoalType.gainMuscle:
        return l10n.goalGainMuscle;
      case GoalType.healthyEating:
        return l10n.goalHealthyEating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileGoalsSection,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            context,
            l10n.profileMainGoalLabel,
            _getLocalizedGoal(context, profile.goal.value),
          ),
          const SizedBox(height: 16),
          _buildAllergies(context, profile.allergies?.value),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllergies(BuildContext context, String? allergies) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.profileAllergiesLabel,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.info_outline,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            allergies == null || allergies.isEmpty
                ? l10n.profileNoAllergies
                : allergies,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
