import 'package:flutter/material.dart';
import 'dart:math' as math;

class MacrosChart extends StatelessWidget {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double size;
  final Color? proteinColor;
  final Color? carbsColor;
  final Color? fatColor;

  const MacrosChart({
    super.key,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.size = 140,
    this.proteinColor,
    this.carbsColor,
    this.fatColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = proteinG + carbsG + fatG;

    if (total == 0) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text('Sin datos', style: theme.textTheme.bodySmall),
        ),
      );
    }

    final proteinPct = proteinG / total;
    final carbsPct = carbsG / total;
    final fatPct = fatG / total;

    final pColor = proteinColor ?? theme.colorScheme.primary;
    final cColor = carbsColor ?? theme.colorScheme.tertiary;
    final fColor = fatColor ?? theme.colorScheme.secondary;

    return CustomPaint(
      painter: MacrosPainter(
        proteinPct: proteinPct,
        carbsPct: carbsPct,
        fatPct: fatPct,
        proteinColor: pColor,
        carbsColor: cColor,
        fatColor: fColor,
      ),
      size: Size(size, size),
    );
  }
}

class MacrosPainter extends CustomPainter {
  final double proteinPct;
  final double carbsPct;
  final double fatPct;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;

  MacrosPainter({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = -math.pi / 2;

    var currentAngle = startAngle;

    // Proteína
    _drawSlice(
      canvas,
      center,
      radius,
      currentAngle,
      proteinPct * 2 * math.pi,
      proteinColor,
    );
    currentAngle += proteinPct * 2 * math.pi;

    // Carbohidratos
    _drawSlice(
      canvas,
      center,
      radius,
      currentAngle,
      carbsPct * 2 * math.pi,
      carbsColor,
    );
    currentAngle += carbsPct * 2 * math.pi;

    // Grasas
    _drawSlice(
      canvas,
      center,
      radius,
      currentAngle,
      fatPct * 2 * math.pi,
      fatColor,
    );
  }

  void _drawSlice(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(MacrosPainter oldDelegate) {
    return oldDelegate.proteinPct != proteinPct ||
        oldDelegate.carbsPct != carbsPct ||
        oldDelegate.fatPct != fatPct;
  }
}
