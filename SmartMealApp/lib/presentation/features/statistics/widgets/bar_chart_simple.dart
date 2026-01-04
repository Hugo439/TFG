import 'package:flutter/material.dart';

/// Gráfico de barras simple para visualizar datos semanales.
///
/// Responsabilidades:
/// - Mostrar barras verticales por día de la semana
/// - Altura proporcional al valor máximo
/// - Labels de días (L, M, X, J, V, S, D)
///
/// Funcionamiento:
/// - values: lista de 7 enteros (uno por día)
/// - maxValue: máximo de la lista
/// - Altura de cada barra: (value / maxValue) * (height - 28)
///
/// Layout:
/// - Row con 7 Expanded children
/// - Cada child: columna con barra + label
/// - crossAxisAlignment.end para alinear abajo
///
/// Barra:
/// - Container con altura proporcional
/// - Background: primary con alpha 0.15
/// - BorderRadius: 8px
/// - Padding horizontal: 6px entre barras
///
/// Labels:
/// - L, M, X, J, V, S, D (Lunes a Domingo)
/// - labelSmall del theme
/// - Color: onSurface con alpha 0.7
/// - Spacing 8px entre barra y label
///
/// Caso sin datos:
/// - Si maxValue == 0: barras de altura 0
/// - Labels siempre visibles
///
/// legendPrefix:
/// - Parámetro opcional no usado actualmente
/// - Para futuras mejoras (prefijo en tooltip)
///
/// Usado en:
/// - StatisticsView: calorías por día de la semana
/// - Muestra tendencias semanales
///
/// Parámetros:
/// [values] - Lista de 7 valores (días de la semana)
/// [height] - Altura total del chart (default: 160)
/// [legendPrefix] - Prefijo opcional para leyenda (no usado)
///
/// Uso:
/// ```dart
/// SimpleBarChart(
///   values: [2000, 2100, 1950, 2200, 2050, 1800, 1900],
///   height: 180,
/// )
/// ```
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
