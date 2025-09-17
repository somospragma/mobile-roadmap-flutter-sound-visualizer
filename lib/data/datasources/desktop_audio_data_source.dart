import 'dart:async';
import 'dart:math' as math;

import 'package:sound_visualizer/core/platform/mock_frequency_spectrum.dart';
import 'package:sound_visualizer/data/datasources/audio_data_source.dart';
import 'package:waveform_fft/waveform_fft.dart';

/// Implementación de AudioDataSource para plataformas de escritorio
/// Simula la captura de audio y genera datos de espectro realistas
class DesktopAudioDataSource implements AudioDataSource {
  final StreamController<List<({FrequencySpectrum spectrum, double value})>> _audioStreamController = 
      StreamController<List<({FrequencySpectrum spectrum, double value})>>.broadcast();
  
  Timer? _simulationTimer;
  bool _isRecording = false;
  
  // Variables para simulación de audio
  final _random = math.Random();
  double _currentValue = 0.0;
  final double _minValue = 0.05;
  final double _maxValue = 0.9;
  final double _changeRate = 0.08; // Velocidad de cambio en la simulación
  
  @override
  Stream<List<({FrequencySpectrum spectrum, double value})>> get audioStream => _audioStreamController.stream;

  @override
  Future<bool> requestPermissions() async {
    // En plataformas de escritorio, no necesitamos permisos especiales
    // para la simulación de audio, así que siempre devolvemos true
    return true;
  }

  @override
  Future<void> startRecording() async {
    if (_isRecording) return;
    
    _isRecording = true;
    _currentValue = _minValue + _random.nextDouble() * 0.2;
    
    // Iniciar la simulación de audio
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _simulateAudioData();
    });
  }

  @override
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isRecording = false;
    
    // Enviar un valor bajo al detener la grabación
    final spectrumData = <({FrequencySpectrum spectrum, double value})>[
      (spectrum: MockFrequencySpectrum.create(value: 0.0), value: 0.0),
    ];
    
    _audioStreamController.add(spectrumData);
  }
  
  /// Simula datos de audio y genera un espectro de frecuencia realista
  void _simulateAudioData() {
    if (!_isRecording) return;
    
    // Simular cambios en la amplitud del audio
    // Usamos una función de ruido para crear cambios suaves pero aleatorios
    _updateSimulatedValue();
    
    // Crear un espectro simulado con el valor actual
    final spectrumData = <({FrequencySpectrum spectrum, double value})>[
      (spectrum: MockFrequencySpectrum.create(value: _currentValue), value: _currentValue),
    ];
    
    _audioStreamController.add(spectrumData);
  }
  
  /// Actualiza el valor simulado de audio usando un algoritmo de ruido
  void _updateSimulatedValue() {
    // Aplicar un cambio aleatorio al valor actual
    double change = (_random.nextDouble() * 2 - 1) * _changeRate;
    
    // Añadir un pequeño impulso aleatorio ocasional para simular picos de audio
    if (_random.nextDouble() < 0.05) {
      change += _random.nextDouble() * 0.3;
    }
    
    _currentValue += change;
    
    // Mantener el valor dentro de los límites
    _currentValue = math.min(_maxValue, math.max(_minValue, _currentValue));
  }

  void dispose() {
    _simulationTimer?.cancel();
    _audioStreamController.close();
  }
}
