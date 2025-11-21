import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/widgets/branding/logo_box.dart';
import 'package:smartmeal/presentation/widgets/branding/app_logo.dart';

class AnimatedLogo extends StatefulWidget {
  final double height;
  final double innerRatio; // 0..1: cuánto ocupa el logo dentro del marco
  final bool useFrame;     // usar o no el LogoBox
  final Duration duration;

  const AnimatedLogo({
    super.key,
    this.height = 110,
    this.innerRatio = 0.95,                 // responsive por defecto
    this.useFrame = true,                   // con marco por defecto
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
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
    Widget content = AppLogo(height: widget.height * (widget.useFrame ? widget.innerRatio : 1.0));
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