import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class GoalsSection extends StatelessWidget {
  final UserProfile profile;

  const GoalsSection({super.key, required this.profile});

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
            l10n.profileGoalsSection,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown(context, l10n.profileMainGoalLabel, profile.goal.displayName),
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
            color: colorScheme.onSurface.withOpacity(0.6),
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
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.arrow_drop_down, 
                color: colorScheme.onSurface.withOpacity(0.6),
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
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 16),
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
            allergies ?? l10n.profileNoAllergies,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}