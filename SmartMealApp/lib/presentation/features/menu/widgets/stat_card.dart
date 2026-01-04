import 'package:flutter/material.dart';

/// Card simple para mostrar una estadística con icono.
///
/// Responsabilidades:
/// - Icono + valor + etiqueta
/// - Diseño compacto horizontal
///
/// Usado en:
/// - RecipeDetailView: stats de receta
/// - DayMenuCard: stats del día (puede ser similar)
/// - Cualquier vista con métricas rápidas
///
/// Layout:
/// - Row: icon + columna (value + label)
/// - Icon: 28px, color personalizable
/// - Value: 20px, bold
/// - Label: 13px, alpha 0.7
///
/// Diseño visual:
/// - Background: primary con alpha 0.08
/// - BorderRadius: 16px
/// - Padding: 16px
/// - Margin bottom: 12px (spacing entre cards)
///
/// Diferencia con MetricCard:
/// - StatCard: horizontal, más compacto
/// - MetricCard: vertical, más espacioso, con unidad
///
/// Parámetros:
/// [icon] - IconData a mostrar
/// [value] - Valor numérico o texto principal
/// [label] - Etiqueta descriptiva
/// [color] - Color del icono
///
/// Uso:
/// ```dart
/// StatCard(
///   icon: Icons.restaurant,
///   value: '12',
///   label: 'Ingredientes',
///   color: Colors.orange,
/// )
/// ```
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
