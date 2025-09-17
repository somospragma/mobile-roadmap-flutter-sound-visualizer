import 'package:waveform_fft/waveform_fft.dart';

class AudioSample {
  final List<double> amplitudes;
  final DateTime timestamp;
  final List<({FrequencySpectrum spectrum, double value})>? spectrumData;

  AudioSample({
    required this.amplitudes,
    required this.timestamp,
    this.spectrumData,
  });
}
