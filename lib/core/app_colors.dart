import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal
  static const MaterialColor primarySwatch = Colors.blueGrey;
  static const Color primary = Colors.blueGrey;
  static const Color primaryVariant = Colors.blue;
  static const Color accent = Colors.blueAccent;

  // Estados semânticos
  static const Color delete = Colors.red;
  static const Color warning = Colors.orange;
  static const Color success = Colors.green;
  static const Color info = Colors.blue;
  static const Color maintenance = Colors.indigo;

  // Neutros básicos
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Cinzas
  static const Color greyLight = Color(0xFFE0E0E0); // ~ grey[300]
  static const Color grey = Color(0xFF9E9E9E); // ~ grey[500]
  static const Color greyDark = Color(0xFF616161); // ~ grey[700]

  // Tons específicos usados na UI
  static const Color fuelGaugeTick = Color.fromRGBO(0, 0, 0, 0.5);
  static const Color purpleLight = Color(0xFF673AB7); // Deep Purple 500
  static const Color purpleDark = Color(0xFFBB86FC); // Roxo mais claro para dark theme

  // Chips
  static const Color chipBackground = Color(0xFFE0E0E0); // grey.shade200 approx
  static const Color chipLabel = Color(0xFF424242); // grey.shade800 approx
  static const Color chipSelected = Color(0xFFB0BEC5); // blueGrey.shade200 approx
  static const Color chipCheckmark = Color(0xFF0D47A1); // blue.shade900 approx

  // Inputs
  static const Color inputBorder = Color(0xFFBDBDBD); // grey.shade400 approx
  static const Color inputLabel = Color(0xFF616161); // grey.shade700 approx

  // Slider
  static const Color sliderInactiveTrack = Color(0xFF90A4AE); // blueGrey.shade300
  static const Color sliderValueIndicator = Color(0xFF455A64); // blueGrey.shade700

  // Texto
  static const Color textPrimary = Colors.black;
  static const Color textOnPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF616161); // ~ grey[700]

  // Fundos
  static const Color surface = Colors.white;
  static const Color progressBackground = Color(0xFFE0E0E0); // ~ grey[300]
  static Color reportCardBackgroundFromTheme(BuildContext context){
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.grey.shade700 : Color(0xFFE3F2FD); // azul bem claro;
  } 

  // Dark theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Outros
  static const Color drawerHeaderForeground = Colors.white;
  static const Color primaryTrackDisabled = Color(0xFFCFD8DC); // blueGrey[100]

  // Helpers dependentes de tema
  static Color purpleFromTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? purpleDark : purpleLight;
  }

  static Color successFromTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // Um verde um pouco mais claro no dark para contraste
    return brightness == Brightness.dark
        ? const Color(0xFF81C784) // Green 300
        : success;
  }

  static Color infoFromTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF64B5F6) // Blue 300
        : info;
  }

  static Color warningFromTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFFFB74D) // Orange 300
        : warning;
  }

  static Color maintenanceFromTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF9FA8DA) // Indigo 200
        : maintenance;
  }

  static Color sliderInactiveFromTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? greyDark
        : sliderInactiveTrack;
  }
}
