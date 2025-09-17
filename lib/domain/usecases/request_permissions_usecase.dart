import '../repositories/audio_repository.dart';

class RequestPermissionsUseCase {
  final AudioRepository repository;

  RequestPermissionsUseCase(this.repository);

  Future<bool> call() async {
    return await repository.requestPermissions();
  }
}
