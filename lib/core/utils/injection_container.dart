import 'package:get_it/get_it.dart';
import 'package:sound_visualizer/core/platform/platform_handler.dart';
import 'package:sound_visualizer/data/datasources/audio_data_source.dart';
import 'package:sound_visualizer/data/datasources/desktop_audio_data_source.dart';
import 'package:sound_visualizer/data/repositories/audio_repository_impl.dart';
import 'package:sound_visualizer/domain/repositories/audio_repository.dart';
import 'package:sound_visualizer/domain/usecases/capture_audio_usecase.dart';
import 'package:sound_visualizer/domain/usecases/request_permissions_usecase.dart';
import 'package:sound_visualizer/domain/usecases/start_recording_usecase.dart';
import 'package:sound_visualizer/domain/usecases/stop_recording_usecase.dart';
import 'package:sound_visualizer/presentation/bloc/audio_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(
    () => AudioBloc(
      captureAudioUseCase: sl(),
      startRecordingUseCase: sl(),
      stopRecordingUseCase: sl(),
      requestPermissionsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CaptureAudioUseCase(sl()));
  sl.registerLazySingleton(() => StartRecordingUseCase(sl()));
  sl.registerLazySingleton(() => StopRecordingUseCase(sl()));
  sl.registerLazySingleton(() => RequestPermissionsUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl(sl()));

  // Data sources
  sl.registerLazySingleton<AudioDataSource>(() {
    if (PlatformHandler.isMobile) {
      return AudioDataSourceImpl();
    } else {
      return DesktopAudioDataSource();
    }
  });
}
