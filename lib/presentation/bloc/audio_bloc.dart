import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_visualizer/domain/usecases/capture_audio_usecase.dart';
import 'package:sound_visualizer/domain/usecases/request_permissions_usecase.dart';
import 'package:sound_visualizer/domain/usecases/start_recording_usecase.dart';
import 'package:sound_visualizer/domain/usecases/stop_recording_usecase.dart';
import 'package:sound_visualizer/presentation/bloc/audio_event.dart';
import 'package:sound_visualizer/presentation/bloc/audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final CaptureAudioUseCase captureAudioUseCase;
  final StartRecordingUseCase startRecordingUseCase;
  final StopRecordingUseCase stopRecordingUseCase;
  final RequestPermissionsUseCase requestPermissionsUseCase;
  
  StreamSubscription? _audioStreamSubscription;
  
  AudioBloc({
    required this.captureAudioUseCase,
    required this.startRecordingUseCase,
    required this.stopRecordingUseCase,
    required this.requestPermissionsUseCase,
  }) : super(AudioInitial()) {
    on<RequestPermissionsEvent>(_onRequestPermissions);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<AudioDataReceivedEvent>(_onAudioDataReceived);
  }
  
  Future<void> _onRequestPermissions(
    RequestPermissionsEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      final granted = await requestPermissionsUseCase();
      emit(AudioPermissionRequested(granted));
    } catch (e) {
      emit(AudioError('Error requesting permissions: ${e.toString()}'));
    }
  }
  
  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await startRecordingUseCase();
      emit(AudioRecordingStarted());
      
      // Listen to audio stream
      _audioStreamSubscription?.cancel();
      _audioStreamSubscription = captureAudioUseCase().listen(
        (audioSample) => add(AudioDataReceivedEvent(audioSample)),
        onError: (error) => emit(AudioError('Error in audio stream: ${error.toString()}')),
      );
    } catch (e) {
      emit(AudioError('Error starting recording: ${e.toString()}'));
    }
  }
  
  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await stopRecordingUseCase();
      _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;
      emit(AudioRecordingStopped());
    } catch (e) {
      emit(AudioError('Error stopping recording: ${e.toString()}'));
    }
  }
  
  void _onAudioDataReceived(
    AudioDataReceivedEvent event,
    Emitter<AudioState> emit,
  ) {
    if (event.audioSample.spectrumData != null) {
      emit(AudioDataReceived(event.audioSample.spectrumData!));
    }
  }
  
  @override
  Future<void> close() {
    _audioStreamSubscription?.cancel();
    return super.close();
  }
}
