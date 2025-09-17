import '../repositories/audio_repository.dart';

class StopRecordingUseCase {
  final AudioRepository repository;

  StopRecordingUseCase(this.repository);

  Future<void> call() async {
    return await repository.stopRecording();
  }
}
