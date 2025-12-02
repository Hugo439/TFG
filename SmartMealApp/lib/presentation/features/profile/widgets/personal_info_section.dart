import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

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
            value: '${profile.bmi.toStringAsFixed(1)} - ${profile.bmiCategory}',
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
                  color: colorScheme.onSurface.withOpacity(0.6),
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