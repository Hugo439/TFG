import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class GenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool isOptional;
  final bool showLabel;

  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.isOptional = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              Text(
                l10n.registerGenderLabel,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isOptional) ...[
                const SizedBox(width: 4),
                Text(
                  l10n.registerOptional,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.registerGenderHint,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
              dropdownColor: colorScheme.surfaceContainerHighest,
              items: [
                DropdownMenuItem(
                  value: 'Masculino',
                  child: Row(
                    children: [
                      Icon(Icons.male, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.registerGenderMale,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Femenino',
                  child: Row(
                    children: [
                      Icon(Icons.female, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.registerGenderFemale,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Otro',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.registerGenderOther,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (v) => onChanged(v ?? ''),
            ),
          ),
        ),
      ],
    );
  }
}
