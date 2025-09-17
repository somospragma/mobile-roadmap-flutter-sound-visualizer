import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_visualizer/core/platform/font_helper.dart';
import 'package:sound_visualizer/presentation/bloc/audio_bloc.dart';
import 'package:sound_visualizer/presentation/widgets/sound_visualizer_widget.dart';

class SoundVisualizerPage extends StatelessWidget {
  const SoundVisualizerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Visualizador de Sonido',
          style: FontHelper.getPoppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocProvider.value(
            value: BlocProvider.of<AudioBloc>(context),
            child: const SoundVisualizerWidget(),
          ),
        ),
      ),
    );
  }
}
