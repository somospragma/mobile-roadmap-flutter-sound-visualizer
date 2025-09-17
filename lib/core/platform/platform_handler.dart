import 'dart:io';

class PlatformHandler {
  /// Verifica si la plataforma actual soporta visualización FFT en tiempo real
  static bool get supportsFFTVisualization {
    // Actualmente, solo iOS y Android son compatibles con waveform_fft
    return Platform.isIOS || Platform.isAndroid;
  }
  
  /// Verifica si estamos en una plataforma de escritorio
  static bool get isDesktop {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }
  
  /// Verifica si estamos en una plataforma móvil
  static bool get isMobile {
    return Platform.isIOS || Platform.isAndroid;
  }
}
