import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_visualizer/core/platform/platform_handler.dart';

/// Clase auxiliar para manejar fuentes en diferentes plataformas
class FontHelper {
  /// Devuelve un TextStyle con la fuente Poppins en plataformas móviles
  /// o una fuente del sistema similar en macOS para evitar problemas de red
  static TextStyle getPoppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    // En plataformas móviles, usar Google Fonts
    if (PlatformHandler.isMobile) {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
    
    // En macOS y otras plataformas de escritorio, usar fuentes del sistema
    return TextStyle(
      fontFamily: 'SF Pro Display', // Fuente similar a Poppins en macOS
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
