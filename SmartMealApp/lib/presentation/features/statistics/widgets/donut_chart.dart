import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gráfico de dona (donut chart) genérico.
///
/// Responsabilidades:
/// - Visualizar proporciones con arcos de círculo
/// - Soporte para múltiples slices con colores
/// - CustomPainter para renderizado
///
/// DonutSlice:
/// - value: valor numérico del slice
/// - color: color del slice
///
/// Cálculo:
/// - total = suma de todos los values
/// - sweep = (value / total) * 2π
/// - Cada slice es un arco proporcional
///
/// _DonutPainter:
/// - CustomPainter con canvas.drawArc
/// - Estilo: stroke (no fill)
/// - strokeWidth: 18% del tamaño
/// - strokeCap: butt (cuadrado)
/// - startAngle: -π/2 (arriba, 12 en punto)
///
/// Orden de dibujado:
/// - Recorre slices secuencialmente
/// - Suma ángulos para siguiente slice
/// - Sin gaps entre slices
///
/// buildDonutSlices:
/// - Helper para crear slices desde Map
/// - Asigna colores de palette cíclicamente
/// - Útil para datos dinámicos
///
/// Caso sin datos:
/// - Si total <= 0: no dibuja nada
/// - Canvas queda vacío
///
/// Diferencia con MacrosChart:
/// - DonutChart: genérico, acepta cualquier slices
/// - MacrosChart: específico para macros (protein/carbs/fat)
///
/// Usado en:
/// - StatisticsView: distribución de categorías
/// - Cualquier visualización de proporciones
///
/// Parámetros:
/// [slices] - Lista de DonutSlice
/// [size] - Tamaño del chart (default: 160)
///
/// Uso:
/// ```dart
/// DonutChart(
///   slices: [
///     DonutSlice(50, Colors.red),
///     DonutSlice(30, Colors.blue),
///     DonutSlice(20, Colors.green),
///   ],
///   size: 180,
/// )
///
/// // Con helper:
/// DonutChart(
///   slices: buildDonutSlices(
///     {'Verduras': 40, 'Proteínas': 30, 'Granos': 30},
///     [Colors.green, Colors.red, Colors.orange],
///   ),
/// )
/// ```
class DonutChart extends StatelessWidget {
  final List<DonutSlice> slices;
  final double size;

  const DonutChart({super.key, required this.slices, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DonutPainter(slices)),
    );
  }
}

class DonutSlice {
  final double value;
  final Color color;
  DonutSlice(this.value, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<DonutSlice> slices;
  _DonutPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;
    final rect = Offset.zero & size;
    final stroke = math.min(size.width, size.height) * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.value / total) * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(
        rect.deflate(stroke / 2 + 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Helper to create slices from a value map
List<DonutSlice> buildDonutSlices(
  Map<String, double> map,
  List<Color> palette,
) {
  final keys = map.keys.toList();
  return [
    for (int i = 0; i < keys.length; i++)
      DonutSlice(map[keys[i]] ?? 0, palette[i % palette.length]),
  ];
}
