import 'package:flutter/material.dart';
import 'package:sound_visualizer/presentation/models/particle.dart';
import 'package:sound_visualizer/presentation/widgets/visualization_type.dart';
import 'package:sound_visualizer/presentation/widgets/waveform_painter.dart';
import 'package:waveform_fft/waveform_fft.dart';

class AllVisualizationsWidget extends StatelessWidget {
  final List<({FrequencySpectrum spectrum, double value})>? spectrumData;
  final List<List<double>> spectrogramHistory;
  final List<Particle> particles;
  final double animationValue;

  const AllVisualizationsWidget({
    super.key,
    required this.spectrumData,
    required this.spectrogramHistory,
    required this.particles,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: VisualizationType.values.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.5, 
      ),
      itemBuilder: (context, index) {
        final type = VisualizationType.values[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[800]!)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CustomPaint(
              painter: WaveformPainter(
                spectrumData: spectrumData,
                spectrogramHistory: spectrogramHistory,
                particles: particles,
                animationValue: animationValue,
                visualizationType: type,
                color: Colors.cyanAccent,
                strokeWidth: 2.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
