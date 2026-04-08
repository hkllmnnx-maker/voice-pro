import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaveformPlayer extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final ValueChanged<Duration>? onSeek;

  const WaveformPlayer({
    super.key,
    required this.duration,
    required this.position,
    this.isPlaying = false,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: GestureDetector(
        onTapDown: (details) {
          if (onSeek != null && duration.inMilliseconds > 0) {
            final box = context.findRenderObject() as RenderBox;
            final ratio = details.localPosition.dx / box.size.width;
            onSeek!(Duration(milliseconds: (duration.inMilliseconds * ratio).toInt()));
          }
        },
        child: CustomPaint(
          painter: _WaveformPlayerPainter(
            duration: duration,
            position: position,
            isPlaying: isPlaying,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _WaveformPlayerPainter extends CustomPainter {
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final Random _random = Random(42);

  _WaveformPlayerPainter({
    required this.duration,
    required this.position,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 3.0;
    final gap = 1.5;
    final totalBarWidth = barWidth + gap;
    final totalBars = (size.width / totalBarWidth).floor();
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;
    final progressBarIndex = (totalBars * progress).floor();

    for (int i = 0; i < totalBars; i++) {
      final x = i * totalBarWidth;
      final amplitude = 0.2 + _random.nextDouble() * 0.8;
      final barHeight = amplitude * size.height * 0.8;
      final y = (size.height - barHeight) / 2;

      final isPast = i <= progressBarIndex;
      final paint = Paint()
        ..color = isPast
            ? AppColors.cyan
            : AppColors.surfaceLight.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }

    // Progress indicator line
    final indicatorX = size.width * progress;
    final indicatorPaint = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(indicatorX, 0),
      Offset(indicatorX, size.height),
      indicatorPaint,
    );

    // Indicator dot
    canvas.drawCircle(
      Offset(indicatorX, size.height / 2),
      5,
      Paint()..color = AppColors.cyan,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPlayerPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.isPlaying != isPlaying;
  }
}
