import 'package:flutter/material.dart';
import 'package:waveform_fft/waveform_fft.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waveform FFT Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _audioCaptureService = AudioCaptureService();
  List<({FrequencySpectrum spectrum, double value})>? _spectrumData;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Aquí iría la solicitud de permisos
  }

  void _startCapture() {
    if (!_isRecording) {
      _audioCaptureService.startCapture((data) {
        setState(() {
          _spectrumData = data;
          
          // Imprimir información sobre la estructura de FrequencySpectrum
          if (data.isNotEmpty) {
            final spectrum = data[0].spectrum;
            print('FrequencySpectrum properties:');
            print('runtimeType: ${spectrum.runtimeType}');
            print('toString: ${spectrum.toString()}');
            
            // Intentar acceder a propiedades
            try {
              final props = spectrum.toString().split(' ')[1].split('(')[1].split(')')[0].split(', ');
              for (final prop in props) {
                print('Property: $prop');
              }
            } catch (e) {
              print('Error parsing properties: $e');
            }
          }
        });
      });
      
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _stopCapture() {
    if (_isRecording) {
      _audioCaptureService.stopCapture();
      setState(() {
        _isRecording = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waveform FFT Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Spectrum Data: ${_spectrumData != null ? _spectrumData!.length : 0} items'),
            if (_spectrumData != null && _spectrumData!.isNotEmpty)
              Text('First item: ${_spectrumData![0]}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopCapture : _startCapture,
              child: Text(_isRecording ? 'Stop Capture' : 'Start Capture'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioCaptureService.stopCapture();
    super.dispose();
  }
}
