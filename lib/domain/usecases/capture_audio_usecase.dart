import '../entities/audio_sample.dart';
import '../repositories/audio_repository.dart';

class CaptureAudioUseCase {
  final AudioRepository repository;

  CaptureAudioUseCase(this.repository);

  Stream<AudioSample> call() {
    return repository.captureAudioStream();
  }
}
