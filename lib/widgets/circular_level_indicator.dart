import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CircularLevelIndicator extends StatelessWidget {
  final double level;
  final double size;

  const CircularLevelIndicator({
    super.key,
    required this.level,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularLevelPainter(level: level),
      ),
    );
  }
}

class _CircularLevelPainter extends CustomPainter {
  final double level;

  _CircularLevelPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Background rings
    for (int i = 3; i >= 0; i--) {
      final ringRadius = maxRadius * (0.4 + i * 0.15);
      final ringPaint = Paint()
        ..color = AppColors.surfaceLight.withValues(alpha: 0.15 + i * 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Active level rings
    final numRings = (level * 5).ceil();
    for (int i = 0; i < numRings; i++) {
      final ringRadius = maxRadius * (0.3 + i * 0.12);
      final ringOpacity = (level - i * 0.2).clamp(0.0, 1.0) * 0.6;

      Color ringColor;
      if (i >= 4) {
        ringColor = AppColors.redAccent;
      } else if (i >= 3) {
        ringColor = AppColors.amber;
      } else {
        ringColor = AppColors.cyan;
      }

      final ringPaint = Paint()
        ..color = ringColor.withValues(alpha: ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Glow ring effect
    final glowRadius = maxRadius * (0.25 + level * 0.35);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.cyan.withValues(alpha: level * 0.3),
          AppColors.cyan.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius + 20));
    canvas.drawCircle(center, glowRadius + 20, glowPaint);

    // dB text
    final db = (-60 + (level * 60)).toStringAsFixed(1);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$db dB',
        style: TextStyle(
          color: AppColors.textPrimary.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + maxRadius * 0.5),
    );

    // Level bars around circle
    final barCount = 36;
    for (int i = 0; i < barCount; i++) {
      final angle = (i / barCount) * 2 * pi - pi / 2;
      final barLevel = level * (0.5 + 0.5 * sin(i * 0.5 + level * 10));
      final innerR = maxRadius * 0.85;
      final outerR = innerR + barLevel * maxRadius * 0.12;

      final startPoint = Offset(
        center.dx + innerR * cos(angle),
        center.dy + innerR * sin(angle),
      );
      final endPoint = Offset(
        center.dx + outerR * cos(angle),
        center.dy + outerR * sin(angle),
      );

      Color barColor;
      if (barLevel > 0.7) {
        barColor = AppColors.redAccent;
      } else if (barLevel > 0.4) {
        barColor = AppColors.amber;
      } else {
        barColor = AppColors.cyan;
      }

      final barPaint = Paint()
        ..color = barColor.withValues(alpha: 0.4 + barLevel * 0.6)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(startPoint, endPoint, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularLevelPainter oldDelegate) {
    return oldDelegate.level != level;
  }
}
