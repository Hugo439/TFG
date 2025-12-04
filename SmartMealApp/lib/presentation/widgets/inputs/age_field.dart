import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class AgeField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool isOptional;

  const AgeField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.isOptional = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.registerAgeLabel,
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
        FilledTextField(
          hintText: l10n.registerAgeHint,
          controller: controller,
          initialValue: initialValue,
          onChanged: onChanged,
          prefixIcon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v != null && v.trim().isNotEmpty) {
              if (int.tryParse(v) == null) {
                return l10n.registerInvalidNumber;
              }
            } else if (!isOptional) {
              return l10n.registerFieldRequiredShort;
            }
            return null;
          },
        ),
      ],
    );
  }
}