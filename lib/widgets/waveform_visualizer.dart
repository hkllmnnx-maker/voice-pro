import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaveformVisualizer extends StatelessWidget {
  final List<double> waveformData;
  final double height;
  final bool isRecording;

  const WaveformVisualizer({
    super.key,
    required this.waveformData,
    this.height = 120,
    this.isRecording = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _WaveformPainter(
          waveformData: waveformData,
          isRecording: isRecording,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final bool isRecording;

  _WaveformPainter({required this.waveformData, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) {
      _drawIdleLine(canvas, size);
      return;
    }

    final barWidth = 3.0;
    final gap = 2.0;
    final totalBarWidth = barWidth + gap;
    final maxBars = (size.width / totalBarWidth).floor();
    final startIdx = max(0, waveformData.length - maxBars);
    final data = waveformData.sublist(startIdx);

    for (int i = 0; i < data.length; i++) {
      final x = i * totalBarWidth;
      final barHeight = data[i] * size.height * 0.8;
      final y = (size.height - barHeight) / 2;

      final opacity = 0.5 + (data[i] * 0.5);
      Color barColor;
      if (data[i] > 0.85) {
        barColor = AppColors.redAccent.withValues(alpha: opacity);
      } else if (data[i] > 0.6) {
        barColor = AppColors.amber.withValues(alpha: opacity);
      } else {
        barColor = AppColors.cyan.withValues(alpha: opacity);
      }

      final paint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  void _drawIdleLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return true;
  }
}
