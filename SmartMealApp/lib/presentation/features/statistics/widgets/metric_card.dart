import 'package:flutter/material.dart';

/// Card para mostrar una métrica numérica con icono.
///
/// Responsabilidades:
/// - Mostrar valor numérico destacado
/// - Icono temático con color
/// - Título descriptivo
/// - Unidad de medida
///
/// Uso principal:
/// - StatisticsView para mostrar métricas nutricionales
/// - Ejemplos: calorías diarias, total comidas, costo, ingredientes
///
/// Diseño visual:
/// - **Background**: color con alpha 0.08 (sutil)
/// - **Bordes redondeados**: 16px
/// - **Icono**: 28px, color personalizable
/// - **Título**: labelMedium, color onSurface con alpha 0.7
/// - **Valor**: headlineMedium, bold, color personalizable
/// - **Unidad**: labelSmall, junto al valor
///
/// Layout:
/// - Columna vertical con crossAxisStart
/// - Icono arriba
/// - Título en medio
/// - Valor + unidad en Row al final
///
/// Responsive:
/// - Valor con Flexible para evitar overflow
/// - maxLines: 1 con ellipsis
/// - Unidad con padding bottom para alineación
///
/// Colores temáticos:
/// - Proteínas: rojo/rosa
/// - Carbohidratos: naranja/amarillo
/// - Grasas: azul/morado
/// - Calorías: primary
/// - Costo: secondary
///
/// Parámetros:
/// [icon] - Icono a mostrar
/// [title] - Título descriptivo
/// [value] - Valor numérico (como String)
/// [unit] - Unidad de medida (ej: "kcal", "€", "ud")
/// [color] - Color del icono y valor
///
/// Uso:
/// ```dart
/// MetricCard(
///   icon: Icons.local_fire_department,
///   title: 'Calorías diarias',
///   value: '2100',
///   unit: 'kcal',
///   color: Colors.orange,
/// )
/// ```
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
