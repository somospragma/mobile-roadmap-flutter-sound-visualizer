import '../entities/audio_sample.dart';

abstract class AudioRepository {
  Stream<AudioSample> captureAudioStream();
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<bool> requestPermissions();
}
