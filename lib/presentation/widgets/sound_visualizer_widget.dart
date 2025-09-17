import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_visualizer/presentation/bloc/audio_bloc.dart';
import 'package:sound_visualizer/presentation/bloc/audio_event.dart';
import 'package:sound_visualizer/presentation/bloc/audio_state.dart';
import 'package:sound_visualizer/presentation/models/particle.dart';
import 'package:sound_visualizer/presentation/widgets/visualization_type.dart';
import 'package:sound_visualizer/presentation/widgets/all_visualizations_widget.dart';
import 'package:sound_visualizer/presentation/widgets/waveform_painter.dart';
import 'package:waveform_fft/waveform_fft.dart';

class SoundVisualizerWidget extends StatefulWidget {
  const SoundVisualizerWidget({super.key});

  @override
  State<SoundVisualizerWidget> createState() => _SoundVisualizerWidgetState();
}

class _SoundVisualizerWidgetState extends State<SoundVisualizerWidget>
    with SingleTickerProviderStateMixin {
  List<({FrequencySpectrum spectrum, double value})>? _spectrumData;
  final List<List<double>> _spectrogramHistory = [];
  static const int _spectrogramHistorySize = 256;
  final List<Particle> _particles = [];
  late AnimationController _animationController;
  bool _isRecording = false;
  VisualizationType _visualizationType = VisualizationType.bar;
  bool _showGridView = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addListener(() {
        final needsUpdate = _visualizationType == VisualizationType.particles ||
            _visualizationType == VisualizationType.geometric ||
            _showGridView;
            
        if (_visualizationType == VisualizationType.particles || _showGridView) {
          _updateParticles();
        }
        
        if (needsUpdate) {
          setState(() {});
        }
      });
    context.read<AudioBloc>().add(RequestPermissionsEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioBloc, AudioState>(
      listener: (context, state) {
        if (state is AudioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state is AudioDataReceived) {
          setState(() {
            _spectrumData = state.spectrum;
            _updateSpectrogramHistory(state.spectrum);
            if (_visualizationType == VisualizationType.particles || _showGridView) {
              _generateParticles(state.spectrum);
            }
          });
        }
      },
      builder: (context, state) {
        if (state is AudioRecordingStarted) {
          _isRecording = true;
          _animationController.repeat();
        } else if (state is AudioRecordingStopped) {
          _isRecording = false;
          _spectrumData = null;
          // No limpiar el historial del espectrograma para que permanezca visible
          _animationController.stop();
        }

        return Column(
          children: [
            Expanded(
              flex: 3,
              child: _showGridView
                  ? AllVisualizationsWidget(
                      spectrumData: _spectrumData,
                      spectrogramHistory: _spectrogramHistory,
                      particles: _particles,
                      animationValue: _animationController.value,
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 200.0),
                        painter: WaveformPainter(
                          spectrumData: _spectrumData,
                          spectrogramHistory: _spectrogramHistory,
                          particles: _particles,
                          animationValue: _animationController.value,
                          visualizationType: _visualizationType,
                          color: Colors.cyanAccent,
                          strokeWidth: 3.0,
                        ),
                      ),
                    ),
            ),
            _buildControls(),
            const SizedBox(height: 24.0),
            Expanded(
              flex: 1,
              child: Center(
                child: GestureDetector(
                  onTapDown: (_) {
                    context.read<AudioBloc>().add(StartRecordingEvent());
                  },
                  onTapUp: (_) {
                    context.read<AudioBloc>().add(StopRecordingEvent());
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red.shade700 : Colors.red,
                      boxShadow: [
                        if (_isRecording)
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...VisualizationType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _visualizationType = type;
                      _showGridView = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_showGridView && _visualizationType == type
                        ? Colors.cyanAccent
                        : Colors.grey[800],
                    foregroundColor: Colors.black,
                  ),
                  child: Text(type.name.capitalize()),
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showGridView = !_showGridView;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _showGridView ? Colors.cyanAccent : Colors.grey[800],
                  foregroundColor: Colors.black,
                ),
                child: const Text('Grid'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _updateSpectrogramHistory(
      List<({FrequencySpectrum spectrum, double value})> spectrum) {
    if (spectrum.isEmpty) return;
    
    // Solo actualizar el historial si estamos en modo espectrograma o vista de cuadrícula
    if (_visualizationType != VisualizationType.spectrogram && !_showGridView) return;

    final bandValues =
        spectrum.map((data) => (data.value / 5000).clamp(0.0, 1.0)).toList();

    _spectrogramHistory.add(bandValues);
    while (_spectrogramHistory.length > _spectrogramHistorySize) {
      _spectrogramHistory.removeAt(0);
    }
  }

  void _generateParticles(List<({FrequencySpectrum spectrum, double value})> spectrum) {
    if (spectrum.isEmpty) return;
    
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, 100);
    final totalEnergy = spectrum.fold<double>(0.0, (sum, data) => sum + data.value) / 5000;

    int particleCount = (totalEnergy * 20).clamp(0, 5).toInt();
    if (particleCount <= 0) return;
    
    final random = Random();
    
    for (int i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = random.nextDouble() * 2.0 + 1.0;
      final velocity = Offset(cos(angle) * speed, sin(angle) * speed);
      _particles.add(
        Particle(
          position: center,
          velocity: velocity,
          radius: random.nextDouble() * 3.0 + 1.0,
          color: Colors.cyanAccent,
        ),
      );
    }
  }

  void _updateParticles() {
    if (_particles.isEmpty) return;
    
    _particles.removeWhere((p) => p.isDead());
    for (var particle in _particles) {
      particle.update();
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
