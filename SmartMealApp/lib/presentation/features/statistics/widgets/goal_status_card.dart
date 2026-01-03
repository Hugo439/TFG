import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class GoalStatusCard extends StatelessWidget {
  final double avgDaily;
  final int? target;
  final double? percent;
  final String? status;

  const GoalStatusCard({
    super.key,
    required this.avgDaily,
    required this.target,
    required this.percent,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = target != null && percent != null && status != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(Icons.flag_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.caloricGoal, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                if (hasData) ...[
                  Text(
                    '${avgDaily.toStringAsFixed(0)} ${context.l10n.kcal} / ${target!.toDouble().toStringAsFixed(0)} ${context.l10n.kcal}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            status!,
                            theme,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getLocalizedStatus(status!, context),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _statusColor(status!, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percent!.toStringAsFixed(0)}${context.l10n.percentOfGoal}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    context.l10n.completeProfileForGoal,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status) {
      case 'highDeficit':
        return theme.colorScheme.tertiary;
      case 'onTarget':
        return theme.colorScheme.primary;
      case 'surplus':
      default:
        return theme.colorScheme.error;
    }
  }

  String _getLocalizedStatus(String status, BuildContext context) {
    switch (status) {
      case 'highDeficit':
        return context.l10n.highDeficit;
      case 'onTarget':
        return context.l10n.onTarget;
      case 'surplus':
        return context.l10n.surplus;
      default:
        return status;
    }
  }
}
