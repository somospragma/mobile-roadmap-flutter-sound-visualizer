import '../repositories/audio_repository.dart';

class StartRecordingUseCase {
  final AudioRepository repository;

  StartRecordingUseCase(this.repository);

  Future<void> call() async {
    return await repository.startRecording();
  }
}
