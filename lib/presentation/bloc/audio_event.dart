import 'package:equatable/equatable.dart';
import 'package:sound_visualizer/domain/entities/audio_sample.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object> get props => [];
}

class RequestPermissionsEvent extends AudioEvent {}

class StartRecordingEvent extends AudioEvent {}

class StopRecordingEvent extends AudioEvent {}

class AudioDataReceivedEvent extends AudioEvent {
  final AudioSample audioSample;

  const AudioDataReceivedEvent(this.audioSample);

  @override
  List<Object> get props => [audioSample];
}
