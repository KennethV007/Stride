import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final TextStyle? style;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    required this.colors,
    this.style,
    this.textAlign,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
} 