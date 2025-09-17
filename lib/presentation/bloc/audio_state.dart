import 'package:equatable/equatable.dart';
import 'package:waveform_fft/waveform_fft.dart';

abstract class AudioState extends Equatable {
  const AudioState();
  
  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioPermissionRequested extends AudioState {
  final bool granted;
  
  const AudioPermissionRequested(this.granted);
  
  @override
  List<Object?> get props => [granted];
}

class AudioRecordingStarted extends AudioState {}

class AudioRecordingStopped extends AudioState {}

class AudioDataReceived extends AudioState {
  final List<({FrequencySpectrum spectrum, double value})> spectrum;

  const AudioDataReceived(this.spectrum);

  @override
  List<Object?> get props => [spectrum];
}

class AudioError extends AudioState {
  final String message;
  
  const AudioError(this.message);
  
  @override
  List<Object?> get props => [message];
}
