import 'package:sound_visualizer/domain/entities/audio_sample.dart';
import 'package:sound_visualizer/domain/repositories/audio_repository.dart';
import 'package:sound_visualizer/data/datasources/audio_data_source.dart';
import 'package:waveform_fft/waveform_fft.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioDataSource dataSource;

  AudioRepositoryImpl(this.dataSource);

  @override
  Stream<AudioSample> captureAudioStream() {
    return dataSource.audioStream.map((spectrumData) => 
      AudioSample(
        // Generar amplitudes simuladas basadas en los datos del espectro
        amplitudes: spectrumData.isNotEmpty 
            ? List.generate(32, (i) => spectrumData[0].value * (0.5 + 0.5 * (i / 32)))
            : [],
        timestamp: DateTime.now(),
        spectrumData: spectrumData,
      )
    );
  }

  @override
  Future<void> startRecording() async {
    return await dataSource.startRecording();
  }

  @override
  Future<void> stopRecording() async {
    return await dataSource.stopRecording();
  }

  @override
  Future<bool> requestPermissions() async {
    return await dataSource.requestPermissions();
  }
}
