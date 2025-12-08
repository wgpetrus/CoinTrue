import 'package:flutter/material.dart';
import 'constants.dart';

/// Helper para acessar cores baseadas no tema atual
/// 
/// Facilita a migração do código existente e fornece
/// acesso às cores corretas baseadas no tema ativo
class ThemeHelper {
  ThemeHelper._();

  /// Obtém as cores corretas baseadas no tema atual
  static AppColors getColors(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }

  /// Verifica se está no modo escuro
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Obtém cor de texto primário baseada no tema
  static Color getPrimaryTextColor(BuildContext context) {
    return getColors(context).onBackground;
  }

  /// Obtém cor de texto secundário baseada no tema
  static Color getSecondaryTextColor(BuildContext context) {
    return getColors(context).onSurface;
  }

  /// Obtém cor de background baseada no tema
  static Color getBackgroundColor(BuildContext context) {
    return getColors(context).background;
  }

  /// Obtém cor de surface baseada no tema
  static Color getSurfaceColor(BuildContext context) {
    return getColors(context).surface;
  }

  /// Obtém cor de outline baseada no tema
  static Color getOutlineColor(BuildContext context) {
    return getColors(context).outline;
  }

  /// Obtém gradiente primário baseado no tema
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final colors = getColors(context);
    return LinearGradient(
      colors: [colors.primary, colors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Obtém cor de sombra baseada no tema
  static Color getShadowColor(BuildContext context) {
    return getColors(context).shadow;
  }

  /// Obtém cor de overlay baseada no tema
  static Color getOverlayColor(BuildContext context) {
    return getColors(context).overlay;
  }
}

/// Extension para facilitar acesso às cores em qualquer Widget
extension ThemeExtension on BuildContext {
  /// Acesso rápido às cores do tema atual
  AppColors get colors => ThemeHelper.getColors(this);
  
  /// Verifica se está no modo escuro
  bool get isDarkMode => ThemeHelper.isDarkMode(this);
  
  /// Gradiente primário
  LinearGradient get primaryGradient => ThemeHelper.getPrimaryGradient(this);
}