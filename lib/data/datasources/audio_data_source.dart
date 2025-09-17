import 'dart:async';
import 'dart:math' as math;
import 'package:permission_handler/permission_handler.dart';
import 'package:waveform_fft/waveform_fft.dart';
import 'package:sound_visualizer/core/platform/platform_handler.dart';
import 'package:sound_visualizer/core/platform/mock_frequency_spectrum.dart';

abstract class AudioDataSource {
  Stream<List<({FrequencySpectrum spectrum, double value})>> get audioStream;
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<bool> requestPermissions();
}

class AudioDataSourceImpl implements AudioDataSource {
  // Solo inicializamos AudioCaptureService en plataformas compatibles
  final AudioCaptureService? _audioCaptureService = 
      PlatformHandler.supportsFFTVisualization ? AudioCaptureService() : null;
  final _audioStreamController = StreamController<List<({FrequencySpectrum spectrum, double value})>>.broadcast();
  
  bool _isRecording = false;
  Timer? _simulationTimer;
  
  AudioDataSourceImpl();
  
  @override
  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  @override
  Stream<List<({FrequencySpectrum spectrum, double value})>> get audioStream => _audioStreamController.stream;
  
  @override
  Future<void> startRecording() async {
    if (_isRecording) return;
    
    // Verificar permisos en plataformas móviles
    if (PlatformHandler.isMobile) {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }
    }
    
    try {
      if (PlatformHandler.supportsFFTVisualization && _audioCaptureService != null) {
        // Iniciar la captura de audio usando waveform_fft en plataformas compatibles
        _audioCaptureService.startCapture((data) {
          if (_isRecording && !_audioStreamController.isClosed) {
            _audioStreamController.add(data);
          }
        });
      } else {
        // En plataformas no compatibles (macOS, etc.), simulamos datos de espectro
        _startSimulation();
      }
      
      _isRecording = true;
    } catch (e) {
      print('Error al iniciar la grabación: $e');
      _isRecording = false;
      rethrow;
    }
  }
  
  // Método para simular datos de espectro en plataformas no compatibles
  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_isRecording && !_audioStreamController.isClosed) {
        // Crear datos de espectro simulados
        final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
        final baseValue = (math.sin(now) + 1) / 2; // Valor entre 0 y 1
        
        // Crear un FrequencySpectrum simulado con datos vacíos
        // Creamos una simulación simplificada para plataformas no compatibles
        // Usamos MockFrequencySpectrum para crear una instancia simulada
        // que es compatible con nuestro WaveformPainter
        final simulatedData = <({FrequencySpectrum spectrum, double value})>[
          (spectrum: MockFrequencySpectrum.create(), value: baseValue),
        ];
        
        _audioStreamController.add(simulatedData);
      }
    });
  }
  
  @override
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    // Detener la captura de audio o simulación según la plataforma
    if (PlatformHandler.supportsFFTVisualization && _audioCaptureService != null) {
      _audioCaptureService.stopCapture();
    } else {
      _simulationTimer?.cancel();
      _simulationTimer = null;
    }
    
    _isRecording = false;
  }
  
  void dispose() async {
    // Detener la grabación si está activa
    if (_isRecording) {
      await stopRecording();
    }
    
    // Cancelar el timer de simulación si existe
    _simulationTimer?.cancel();
    
    // Cerrar el stream controller
    if (!_audioStreamController.isClosed) {
      _audioStreamController.close();
    }
  }
}
