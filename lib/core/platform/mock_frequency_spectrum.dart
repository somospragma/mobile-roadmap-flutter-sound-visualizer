import 'dart:math' as math;
import 'package:waveform_fft/waveform_fft.dart';

/// Clase que simula FrequencySpectrum para plataformas no compatibles
class MockFrequencySpectrum implements FrequencySpectrum {
  final List<double> _bands;
  final double _value;
  
  /// Constructor privado para crear una instancia con bandas y valor
  MockFrequencySpectrum._({List<double>? bands, double value = 0.0})
      : _bands = bands ?? List.filled(64, 0.0),
        _value = value;
  
  /// Crea una instancia simulada de FrequencySpectrum que puede usarse
  /// en plataformas donde waveform_fft no es compatible (como macOS)
  static FrequencySpectrum create({double value = 0.0}) {
    return MockFrequencySpectrum._(
      value: value,
      bands: _generateBands(value),
    );
  }
  
  /// Genera bandas de frecuencia simuladas basadas en un valor de amplitud
  /// Esto crea un patrón de visualización similar a un espectro real
  static List<double> _generateBands(double value) {
    final random = math.Random();
    final bands = <double>[];
    
    // Generar 64 bandas de frecuencia (típico en visualizadores FFT)
    for (int i = 0; i < 64; i++) {
      // Crear un patrón que simule un espectro de frecuencia
      // Las frecuencias bajas (índices bajos) suelen tener más energía
      double bandValue = 0.0;
      
      // Valor base proporcional al valor de entrada
      bandValue = value * math.max(0.0, 1.0 - (i / 64) * 0.8);
      
      // Añadir variación aleatoria para simular fluctuaciones naturales
      bandValue += random.nextDouble() * value * 0.3;
      
      // Asegurar que el valor esté en el rango [0.0, 1.0]
      bandValue = math.min(1.0, math.max(0.0, bandValue));
      
      bands.add(bandValue);
    }
    
    return bands;
  }
  
  /// Implementación de getBandLevel para acceder a las bandas simuladas
  double getBandLevel(int index) {
    if (index < 0 || index >= _bands.length) return 0.0;
    return _bands[index];
  }
  
  /// Implementación de getNumBands para informar el número de bandas disponibles
  int getNumBands() {
    return _bands.length;
  }
  
  /// Devuelve el valor base usado para generar este espectro
  double getValue() {
    return _value;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Intentar manejar los métodos comunes de FrequencySpectrum
    if (invocation.memberName == Symbol('getBandLevel') && 
        invocation.positionalArguments.length == 1 &&
        invocation.positionalArguments[0] is int) {
      return getBandLevel(invocation.positionalArguments[0] as int);
    }
    
    if (invocation.memberName == Symbol('getNumBands') && 
        invocation.positionalArguments.isEmpty) {
      return getNumBands();
    }
    
    // Para cualquier otro método, devolver un valor predeterminado
    return 0.0;
  }
}
