# Sound Visualizer

Una aplicación Flutter multiplataforma para visualización de espectro de audio en tiempo real. Captura audio del micrófono y muestra representaciones visuales interactivas del espectro de frecuencias con múltiples modos de visualización.

## Características

- Captura de audio en tiempo real del micrófono del dispositivo
- Procesamiento FFT (Fast Fourier Transform) para análisis de espectro de frecuencias
- Seis modos de visualización diferentes e interactivos:
  - **Barras**: Visualización clásica de barras de espectro con gradiente de color
  - **Circular**: Representación radial del espectro de frecuencias
  - **Línea**: Visualización suave de ondas con interpolación de curvas
  - **Espectrograma**: Historial de intensidad de frecuencias a lo largo del tiempo
  - **Partículas**: Sistema de partículas dinámico que responde a la energía del audio
  - **Geométrico**: Formas geométricas que rotan y pulsan según el audio
- Vista de cuadrícula que muestra los seis modos de visualización simultáneamente
- Interfaz de usuario moderna con tema oscuro y controles intuitivos
- Botón de grabación con gesto de presionar y mantener
- Animaciones fluidas y transiciones suaves entre modos
- Soporte multiplataforma (con limitaciones específicas por plataforma)

## Compatibilidad de plataformas

### Funcionalidad completa (FFT real)
- Android ✅
- iOS ✅

### Funcionalidad limitada (simulación)
- macOS ⚠️ (usa simulación de datos de espectro)
- Windows ⚠️ (usa simulación de datos de espectro)
- Linux ⚠️ (usa simulación de datos de espectro)
- Web ⚠️ (usa simulación de datos de espectro)

## Arquitectura y Diseño

El proyecto sigue los principios de Clean Architecture, organizando el código en tres capas principales:

- **Presentación**: Widgets, BLoC para gestión de estado, y pintores personalizados
- **Dominio**: Modelos de negocio, casos de uso y abstracciones de repositorios
- **Datos**: Implementaciones concretas para captura de audio y procesamiento FFT

### Componentes Principales

- **AudioBloc**: Gestiona los estados de grabación y procesamiento de audio
- **SoundVisualizerWidget**: Widget principal que coordina la visualización y controles
- **WaveformPainter**: CustomPainter que implementa los diferentes modos de visualización
- **AllVisualizationsWidget**: Widget que muestra una cuadrícula con todos los modos
- **Particle**: Modelo para el sistema de partículas dinámicas

## Limitaciones técnicas

### Visualización FFT en macOS y otras plataformas de escritorio

La aplicación utiliza el paquete `waveform_fft` para la captura y procesamiento FFT del audio. Este paquete depende de `flutter_audio_capture`, que solo es compatible con iOS y Android.

En plataformas no compatibles (como macOS, Windows, Linux y Web), la aplicación utiliza una simulación de datos de espectro para mantener la visualización funcional, aunque no representa el audio real capturado del micrófono.

### Solución implementada

Para asegurar que la aplicación funcione en todas las plataformas:

1. Se implementó una clase `MockFrequencySpectrum` que simula la estructura de `FrequencySpectrum` en plataformas no compatibles.
2. Se utiliza `PlatformHandler` para detectar la plataforma y aplicar la lógica adecuada.
3. En plataformas no compatibles, se genera una visualización simulada basada en valores aleatorios.
4. El sistema de visualización está diseñado para funcionar con cualquier fuente de datos que proporcione valores de espectro.

## Alternativas para soporte multiplataforma completo

Para implementar una visualización FFT real en todas las plataformas, se podrían explorar las siguientes alternativas:

1. Desarrollar plugins nativos específicos para cada plataforma que capturen audio PCM y lo procesen con FFT.
2. Utilizar paquetes como `just_audio` con extensiones para captura de audio en plataformas de escritorio.
3. Implementar el procesamiento FFT en Dart puro utilizando paquetes como `fft` o `spectrum_analyzer`.

## Requisitos Técnicos

- Flutter SDK >= 3.8.1
- Dart SDK >= 3.8.1
- Dependencias principales:
  - `flutter_bloc`: Para gestión de estado
  - `waveform_fft`: Para procesamiento FFT de audio
  - `equatable`: Para comparaciones de objetos

## Comenzando

### Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/sound_visualizer.git
   cd sound_visualizer
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

### Uso

1. Presiona y mantén el botón rojo del micrófono para iniciar la grabación
2. Suelta el botón para detener la grabación
3. Selecciona entre los diferentes modos de visualización usando los botones en la parte superior
4. Usa el botón "Grid" para alternar entre la vista individual y la vista de cuadrícula

## Personalización

El código está diseñado para ser fácilmente extensible:

- Para añadir un nuevo modo de visualización:
  1. Añade un nuevo valor al enum `VisualizationType`
  2. Implementa un nuevo método `_draw...` en `WaveformPainter`
  3. Añade el caso correspondiente en el switch del método `paint`

- Para personalizar colores y estilos:
  - Modifica los valores de color en los métodos de dibujo
  - Ajusta los parámetros de sensibilidad en los métodos de normalización
