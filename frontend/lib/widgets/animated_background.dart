import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getFlowingColors(),
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }

  List<Color> _getFlowingColors() {
    final time = _animation.value * 2 * math.pi;
    
    // Create smooth, wave-like color transitions using sine waves
    final purpleIntensity = 0.5 + 0.3 * math.sin(time * 0.8);
    final cyanIntensity = 0.5 + 0.3 * math.sin(time * 1.2 + math.pi / 3);
    final darkBlueIntensity = 0.5 + 0.2 * math.sin(time * 0.6 + math.pi / 2);
    
    // Base colors
    const baseDark = Color(0xFF0F172A);
    const baseMedium = Color(0xFF1E293B);
    const purple = Color(0xFF8B5CF6);
    const cyan = Color(0xFF06B6D4);
    
    // Create flowing colors by blending with sine wave intensity
    final flowingPurple = Color.lerp(baseMedium, purple, purpleIntensity)!;
    final flowingCyan = Color.lerp(baseMedium, cyan, cyanIntensity)!;
    final flowingDark = Color.lerp(baseDark, baseMedium, darkBlueIntensity)!;
    
    return [
      flowingDark,
      flowingPurple,
      flowingCyan,
      flowingDark,
    ];
  }
}

// Alternative: Wave-like animated background with moving gradients
class WaveAnimatedBackground extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const WaveAnimatedBackground({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<WaveAnimatedBackground> createState() => _WaveAnimatedBackgroundState();
}

class _WaveAnimatedBackgroundState extends State<WaveAnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            animation: _animation,
          ),
          size: Size.infinite,
          child: widget.child,
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;

  WavePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.sin(animation.value * 2 * math.pi) * 0.3,
          math.cos(animation.value * 2 * math.pi) * 0.3,
        ),
        radius: 1.0,
        colors: [
          const Color(0xFF8B5CF6).withOpacity(0.3),
          const Color(0xFF06B6D4).withOpacity(0.2),
          const Color(0xFF0F172A).withOpacity(0.8),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Add subtle wave patterns
    final wavePaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveOffset = animation.value * 2 * math.pi + i * math.pi / 2;
      
      path.moveTo(0, size.height * 0.5);
      
      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.5 + 
                  math.sin(x * 0.01 + waveOffset) * 50 +
                  math.sin(x * 0.005 + waveOffset * 0.5) * 30;
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Alternative: Animated gradient with moving particles
class ParticleAnimatedBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Duration duration;

  const ParticleAnimatedBackground({
    super.key,
    required this.child,
    this.particleCount = 50,
    this.duration = const Duration(seconds: 20),
  });

  @override
  State<ParticleAnimatedBackground> createState() => _ParticleAnimatedBackgroundState();
}

class _ParticleAnimatedBackgroundState extends State<ParticleAnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _particleAnimations;
  late List<Offset> _particlePositions;
  late List<double> _particleSizes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particlePositions = List.generate(
      widget.particleCount,
      (index) => Offset(
        math.Random().nextDouble(),
        math.Random().nextDouble(),
      ),
    );

    _particleSizes = List.generate(
      widget.particleCount,
      (index) => math.Random().nextDouble() * 0.02 + 0.005,
    );

    _particleAnimations = List.generate(
      widget.particleCount,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      )),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
          ),
        ),
        
        // Animated particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particlePositions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final position = entry.value;
                  final animation = _particleAnimations[index];
                  final size = _particleSizes[index];
                  
                  return Particle(
                    position: Offset(
                      (position.dx + animation.value) % 1.0,
                      (position.dy + animation.value * 0.5) % 1.0,
                    ),
                    size: size,
                    opacity: (0.3 + 0.7 * math.sin(animation.value * 2 * math.pi)) * 0.3,
                  );
                }).toList(),
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}

class Particle {
  final Offset position;
  final double size;
  final double opacity;

  Particle({
    required this.position,
    required this.size,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = const Color(0xFF8B5CF6).withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.size * size.width,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 