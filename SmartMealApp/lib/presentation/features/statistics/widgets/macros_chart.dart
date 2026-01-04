import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Gráfico de dona para mostrar distribución de macronutrientes.
///
/// Responsabilidades:
/// - Visualizar proporción de proteínas, carbohidratos y grasas
/// - Gráfico de dona (donut chart) con CustomPainter
/// - Colores personalizables por macro
///
/// Funcionamiento:
/// - Recibe gramos de cada macronutriente
/// - Calcula porcentajes relativos
/// - Dibuja arcos proporcionales en círculo
///
/// Cálculo de porcentajes:
/// - Total = proteinG + carbsG + fatG
/// - proteinPct = proteinG / total
/// - carbsPct = carbsG / total
/// - fatPct = fatG / total
///
/// Orden de dibujado:
/// - Proteínas (rojo/rosa)
/// - Carbohidratos (naranja/amarillo)
/// - Grasas (azul/morado)
///
/// Caso sin datos:
/// - Si total == 0, muestra "Sin datos"
/// - SizedBox con tamaño especificado
///
/// Colores por defecto:
/// - proteinColor: primary del theme
/// - carbsColor: tertiary del theme
/// - fatColor: secondary del theme
///
/// MacrosPainter:
/// - CustomPainter que dibuja los arcos
/// - Grosor del arco configurable
/// - Espacio central (dona, no pie chart completo)
///
/// Responsive:
/// - Tamaño configurable con parámetro size
/// - Default: 140x140
/// - Escala proporcional del grosor
///
/// Parámetros:
/// [proteinG] - Gramos de proteínas
/// [carbsG] - Gramos de carbohidratos
/// [fatG] - Gramos de grasas
/// [size] - Tamaño del gráfico (default: 140)
/// [proteinColor] - Color para proteínas (opcional)
/// [carbsColor] - Color para carbohidratos (opcional)
/// [fatColor] - Color para grasas (opcional)
///
/// Uso:
/// ```dart
/// MacrosChart(
///   proteinG: 150.0,
///   carbsG: 300.0,
///   fatG: 80.0,
///   size: 180,
/// )
/// ```
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
