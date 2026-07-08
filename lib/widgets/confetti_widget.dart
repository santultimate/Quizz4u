import 'package:flutter/material.dart';
import 'dart:math';

/// Widget de confetti moderne pour célébrer les succès
class ConfettiWidget extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  final int numberOfParticles;

  const ConfettiWidget({
    super.key,
    required this.isActive,
    this.duration = const Duration(seconds: 2),
    this.numberOfParticles = 50,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _generateParticles();
      _controller.forward(from: 0.0);
    }
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < widget.numberOfParticles; i++) {
      _particles.add(
        ConfettiParticle(
          color: _getRandomColor(),
          startX: _random.nextDouble(),
          startY: -0.1,
          endX: _random.nextDouble(),
          endY: 1.1 + _random.nextDouble() * 0.3,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10,
          size: 8 + _random.nextDouble() * 8,
          shape: _random.nextInt(3), // 0: carré, 1: cercle, 2: triangle
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        ),
      ),
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final int shape;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.shape,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - (progress * 0.5))
        ..style = PaintingStyle.fill;

      // Calcul de la position actuelle avec effet de chute
      final currentX = particle.startX +
          (particle.endX - particle.startX) * _easeOutCubic(progress) +
          sin(progress * 4 * pi) * 0.05;
      final currentY = particle.startY +
          (particle.endY - particle.startY) * _easeInCubic(progress);

      final x = currentX * size.width;
      final y = currentY * size.height;

      // Rotation
      final currentRotation =
          particle.rotation + particle.rotationSpeed * progress;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      // Dessiner la forme
      switch (particle.shape) {
        case 0: // Carré
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 1: // Cercle
          canvas.drawCircle(
            Offset.zero,
            particle.size / 2,
            paint,
          );
          break;
        case 2: // Triangle
          final path = Path();
          path.moveTo(0, -particle.size / 2);
          path.lineTo(particle.size / 2, particle.size / 2);
          path.lineTo(-particle.size / 2, particle.size / 2);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  double _easeOutCubic(double t) {
    return 1 - pow(1 - t, 3).toDouble();
  }

  double _easeInCubic(double t) {
    return pow(t, 3).toDouble();
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget simplifié pour déclencher des confettis
class ConfettiOverlay extends StatefulWidget {
  final Widget child;

  const ConfettiOverlay({super.key, required this.child});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();

  static ConfettiOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<ConfettiOverlayState>();
  }
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  bool _isActive = false;

  void showConfetti() {
    setState(() {
      _isActive = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isActive = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ConfettiWidget(isActive: _isActive),
      ],
    );
  }
}







