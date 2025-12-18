import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final List<int> values;
  final double height;
  final String? legendPrefix;

  const SimpleBarChart({
    super.key,
    required this.values,
    this.height = 160,
    this.legendPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue =
        (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b))
            .toDouble();
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: maxValue == 0
                              ? 0
                              : (values[i] / maxValue) * (height - 28),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dayLabel(i),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _dayLabel(int i) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return i >= 0 && i < labels.length ? labels[i] : '';
  }
}
