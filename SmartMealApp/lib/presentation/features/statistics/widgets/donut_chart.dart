import 'dart:math' as math;
import 'package:flutter/material.dart';

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
