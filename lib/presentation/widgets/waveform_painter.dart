import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sound_visualizer/presentation/models/particle.dart';
import 'package:sound_visualizer/presentation/widgets/visualization_type.dart';
import 'package:waveform_fft/waveform_fft.dart';

class WaveformPainter extends CustomPainter {
  final List<({FrequencySpectrum spectrum, double value})>? spectrumData;
  final List<List<double>> spectrogramHistory;
  final List<Particle> particles;
  final double animationValue;
  final VisualizationType visualizationType;
  final Color color;
  final double strokeWidth;

  WaveformPainter({
    required this.spectrumData,
    required this.spectrogramHistory,
    required this.particles,
    required this.animationValue,
    required this.visualizationType,
    this.color = Colors.blue,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spectrumData == null || spectrumData!.isEmpty) {
      _drawSilentWave(canvas, size);
      return;
    }

    switch (visualizationType) {
      case VisualizationType.bar:
        _drawBar(canvas, size);
        break;
      case VisualizationType.circular:
        _drawCircular(canvas, size);
        break;
      case VisualizationType.line:
        _drawLine(canvas, size);
        break;
      case VisualizationType.spectrogram:
        _drawSpectrogram(canvas, size);
        break;
      case VisualizationType.particles:
        _drawParticles(canvas, size);
        break;
      case VisualizationType.geometric:
        _drawGeometric(canvas, size);
        break;
    }
  }

  void _drawBar(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = strokeWidth;
    final width = size.width;
    final height = size.height;
    final barCount = spectrumData!.length;
    final barWidth = width / barCount;
    final spacing = barWidth * 0.2;
    final effectiveBarWidth = barWidth - spacing;

    final gradient = LinearGradient(
      colors: [color.withOpacity(0.5), color],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    for (int i = 0; i < barCount; i++) {
      final data = spectrumData![i];
      final bandValue = data.value;
      final normalizedValue = (bandValue / 5000).clamp(0.0, 1.0);
      final barHeight = normalizedValue * height;

      final rect = Rect.fromLTWH(
        i * barWidth + spacing / 2,
        height - barHeight,
        effectiveBarWidth,
        barHeight,
      );

      paint.shader = gradient.createShader(rect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4.0)),
        paint,
      );
    }
  }

  void _drawCircular(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final minRadius = size.width * 0.1;
    final maxRadius = size.width * 0.4;
    final barCount = spectrumData!.length;
    final angleStep = 2 * pi / barCount;

    final paint = Paint()
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < barCount; i++) {
      final data = spectrumData![i];
      final normalizedValue = (data.value / 5000).clamp(0.0, 1.0);
      final barLength = minRadius + normalizedValue * (maxRadius - minRadius);

      final startX = center.dx + minRadius * cos(i * angleStep);
      final startY = center.dy + minRadius * sin(i * angleStep);
      final endX = center.dx + barLength * cos(i * angleStep);
      final endY = center.dy + barLength * sin(i * angleStep);

      paint.color = Color.lerp(Colors.blue, Colors.red, normalizedValue)!;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  void _drawLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final barCount = spectrumData!.length;
    final barWidth = width / barCount;

    final points = <Offset>[];
    for (int i = 0; i < barCount; i++) {
      final data = spectrumData![i];
      final normalizedValue = (data.value / 5000).clamp(0.0, 1.0);
      final y = height - normalizedValue * height;
      points.add(Offset(i * barWidth, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
          controlPoint2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawSpectrogram(Canvas canvas, Size size) {
    if (spectrogramHistory.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final rowHeight = height / spectrogramHistory.length;

    for (int i = 0; i < spectrogramHistory.length; i++) {
      final bandValues = spectrogramHistory[i];
      final colWidth = width / bandValues.length;
      for (int j = 0; j < bandValues.length; j++) {
        final paint = Paint()
          ..color = Color.lerp(
              Colors.black, Colors.cyanAccent, bandValues[j])!;
        canvas.drawRect(
          Rect.fromLTWH(j * colWidth, i * rowHeight, colWidth, rowHeight),
          paint,
        );
      }
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.lifespan)
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  void _drawGeometric(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final totalEnergy = spectrumData!
        .fold<double>(0.0, (sum, data) => sum + data.value)
        .clamp(0, 5000);
    final radius = (totalEnergy / 5000) * (size.width * 0.3) + size.width * 0.1;

    final paint = Paint()
      ..color = Color.lerp(Colors.purple, Colors.yellow, totalEnergy / 5000)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    const sides = 6;
    final angle = (pi * 2) / sides;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animationValue * 2 * pi);
    canvas.translate(-center.dx, -center.dy);

    final startPoint = Offset(center.dx + radius * cos(0), center.dy + radius * sin(0));
    path.moveTo(startPoint.dx, startPoint.dy);

    for (int i = 1; i <= sides; i++) {
      final x = center.dx + radius * cos(angle * i);
      final y = center.dy + radius * sin(angle * i);
      path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawSilentWave(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final height = size.height / 2;
    path.moveTo(0, height);
    for (double i = 0; i < size.width; i++) {
      path.lineTo(i, height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.spectrumData != spectrumData ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.visualizationType != visualizationType ||
        oldDelegate.spectrogramHistory.length != spectrogramHistory.length ||
        oldDelegate.particles.length != particles.length;
  }
}
