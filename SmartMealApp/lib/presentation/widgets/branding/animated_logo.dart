import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/widgets/branding/logo_box.dart';
import 'package:smartmeal/presentation/widgets/branding/app_logo.dart';

/// Logo animado de SmartMeal con transición de entrada.
///
/// Responsabilidades:
/// - Mostrar logo de la app con animación
/// - Transición suave en splash screen
/// - Configurable con/sin marco
///
/// Componentes:
/// - **AppLogo**: SVG del logo (verde con texto)
/// - **LogoBox**: Marco decorativo opcional
/// - **Animaciones**: scale + fade in
///
/// Animaciones:
/// 1. **Scale**: 0.85 → 1.0
///    - Curve: easeOutBack (rebote sutil)
///    - Efecto: logo crece desde pequeño
/// 2. **Fade**: 0 → 1
///    - Curve: easeIn
///    - Efecto: aparece gradualmente
///
/// Duración:
/// - Default: 900ms
/// - Configurable con parámetro duration
/// - Ambas animaciones sincronizadas
///
/// Tamaños:
/// - height: altura total del widget
/// - innerRatio: proporción del logo dentro del marco (0-1)
/// - Si useFrame=false, innerRatio se ignora
///
/// Modos:
/// 1. **Con marco** (useFrame=true):
///    - LogoBox + AppLogo dentro
///    - innerRatio controla tamaño relativo
///    - Default: innerRatio 0.95
/// 2. **Sin marco** (useFrame=false):
///    - Solo AppLogo
///    - height se aplica directamente
///
/// Lifecycle:
/// - initState: crea AnimationController y forward()
/// - build: AnimatedBuilder con Transform.scale + Opacity
/// - dispose: limpia AnimationController
///
/// Parámetros:
/// [height] - Altura total del widget (default: 110)
/// [innerRatio] - Proporción del logo en el marco (default: 0.95)
/// [useFrame] - Usar LogoBox como marco (default: true)
/// [duration] - Duración de las animaciones (default: 900ms)
///
/// Uso:
/// ```dart
/// // En splash screen con marco
/// AnimatedLogo(height: 180)
///
/// // Solo logo sin marco
/// AnimatedLogo(
///   height: 120,
///   useFrame: false,
/// )
/// ```
class AnimatedLogo extends StatefulWidget {
  final double height;
  final double innerRatio; // 0..1: cuánto ocupa el logo dentro del marco
  final bool useFrame; // usar o no el LogoBox
  final Duration duration;

  const AnimatedLogo({
    super.key,
    this.height = 110,
    this.innerRatio = 0.95, // responsive por defecto
    this.useFrame = true, // con marco por defecto
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..forward();
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AppLogo(
      height: widget.height * (widget.useFrame ? widget.innerRatio : 1.0),
    );
    if (widget.useFrame) {
      content = LogoBox(height: widget.height, child: content);
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: _fade.value.clamp(0, 1),
        child: Transform.scale(
          scale: _scale.value.clamp(0.85, 1.0),
          child: content,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
