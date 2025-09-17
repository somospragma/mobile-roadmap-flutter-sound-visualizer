# Sound Visualizer

Una aplicación Flutter para visualización de espectro de audio en tiempo real. Captura audio del micrófono y muestra una representación visual del espectro de frecuencias.

## Características

- Captura de audio en tiempo real del micrófono
- Visualización de espectro de frecuencias (FFT)
- Interfaz de usuario moderna y atractiva
- Botón de grabación con modo toggle (iniciar/detener)
- Soporte multiplataforma (con limitaciones)

## Compatibilidad de plataformas

### Funcionalidad completa (FFT real)
- Android ✅
- iOS ✅

### Funcionalidad limitada (simulación)
- macOS ⚠️ (usa simulación de datos de espectro)
- Windows ⚠️ (usa simulación de datos de espectro)
- Linux ⚠️ (usa simulación de datos de espectro)
- Web ⚠️ (usa simulación de datos de espectro)

## Limitaciones técnicas

### Visualización FFT en macOS y otras plataformas de escritorio

La aplicación utiliza el paquete `waveform_fft` para la captura y procesamiento FFT del audio. Este paquete depende de `flutter_audio_capture`, que solo es compatible con iOS y Android.

En plataformas no compatibles (como macOS, Windows, Linux y Web), la aplicación utiliza una simulación de datos de espectro para mantener la visualización funcional, aunque no representa el audio real capturado del micrófono.

### Solución implementada

Para asegurar que la aplicación funcione en todas las plataformas:

1. Se implementó una clase `MockFrequencySpectrum` que simula la estructura de `FrequencySpectrum` en plataformas no compatibles.
2. Se utiliza `PlatformHandler` para detectar la plataforma y aplicar la lógica adecuada.
3. En plataformas no compatibles, se genera una visualización simulada basada en valores aleatorios.

## Alternativas para soporte multiplataforma completo

Para implementar una visualización FFT real en todas las plataformas, se podrían explorar las siguientes alternativas:

1. Desarrollar plugins nativos específicos para cada plataforma que capturen audio PCM y lo procesen con FFT.
2. Utilizar paquetes como `just_audio` con extensiones para captura de audio en plataformas de escritorio.
3. Implementar el procesamiento FFT en Dart puro utilizando paquetes como `fft` o `spectrum_analyzer`.

## Comenzando

Para ejecutar este proyecto:

```bash
flutter pub get
flutter run
```
