import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Widget pour afficher un graphique de progression circulaire
class CircularProgressChart extends StatefulWidget {
  final double progress; // 0.0 à 1.0
  final String label;
  final Color color;
  final double size;

  const CircularProgressChart({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
    this.size = 120,
  });

  @override
  State<CircularProgressChart> createState() => _CircularProgressChartState();
}

class _CircularProgressChartState extends State<CircularProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CircularChartPainter(
                progress: _animation.value,
                color: widget.color,
              ),
            );
          },
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          widget.label,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CircularChartPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularChartPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    // Percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(CircularChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget pour afficher un graphique en barres
class BarChart extends StatefulWidget {
  final List<BarChartData> data;
  final double height;

  const BarChart({
    super.key,
    required this.data,
    this.height = 200,
  });

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Aucune donnée disponible',
            style: AppTextStyles.caption,
          ),
        ),
      );
    }

    final maxValue =
        widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final animationDelay = index * 0.1;
                final adjustedValue = _controller.value - animationDelay;
                final barHeight = adjustedValue < 0
                    ? 0.0
                    : ((widget.height - 50) *
                        (item.value / maxValue) *
                        min(adjustedValue / 0.9, 1.0));

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.value.toStringAsFixed(0),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Container(
                        width: double.infinity,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              item.color,
                              item.color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusSm),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        item.label,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BarChartData {
  final String label;
  final double value;
  final Color color;

  BarChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}
