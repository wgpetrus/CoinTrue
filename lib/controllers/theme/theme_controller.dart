import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller para gerenciar o tema da aplicação
/// 
/// Responsável por:
/// - Alternar entre light e dark mode
/// - Persistir preferência do usuário
/// - Detectar tema do sistema
/// - Notificar mudanças para a UI
class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeController() {
    _loadThemeMode();
  }

  /// Modo de tema atual
  ThemeMode get themeMode => _themeMode;

  /// Se está no modo escuro (considerando tema do sistema)
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  /// Carrega preferência salva
  Future<void> _loadThemeMode() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedTheme = _prefs?.getString(_themeKey);
      
      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ThemeController: Erro ao carregar tema: $e');
    }
  }

  /// Salva preferência
  Future<void> _saveThemeMode() async {
    try {
      await _prefs?.setString(_themeKey, _themeMode.toString());
    } catch (e) {
      debugPrint('ThemeController: Erro ao salvar tema: $e');
    }
  }

  /// Alterna para modo claro
  Future<void> setLightMode([BuildContext? context]) async {
    if (_themeMode != ThemeMode.light) {
      _themeMode = ThemeMode.light;
      notifyListeners();
      await _saveThemeMode();
      _showThemeChangedSnackBar(context, 'Tema alterado para Claro');
    }
  }

  /// Alterna para modo escuro
  Future<void> setDarkMode([BuildContext? context]) async {
    if (_themeMode != ThemeMode.dark) {
      _themeMode = ThemeMode.dark;
      notifyListeners();
      await _saveThemeMode();
      _showThemeChangedSnackBar(context, 'Tema alterado para Escuro');
    }
  }

  /// Alterna para seguir sistema
  Future<void> setSystemMode([BuildContext? context]) async {
    if (_themeMode != ThemeMode.system) {
      _themeMode = ThemeMode.system;
      notifyListeners();
      await _saveThemeMode();
      _showThemeChangedSnackBar(context, 'Tema alterado para Sistema');
    }
  }

  /// Mostra snackbar de confirmação da mudança de tema
  void _showThemeChangedSnackBar(BuildContext? context, String message) {
    if (context != null && context.mounted) {
      // Limpa snackbars existentes primeiro
      ScaffoldMessenger.of(context).clearSnackBars();
      
      // Aguarda um frame para garantir que o tema foi aplicado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    _getThemeIcon(),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2563EB), // Cor fixa para evitar problemas
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    }
  }

  /// Retorna ícone do tema atual
  IconData _getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Alterna entre os modos (para toggle simples)
  Future<void> toggleTheme(BuildContext context) async {
    final currentlyDark = isDarkMode(context);
    
    if (currentlyDark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  /// Retorna o nome do modo atual para exibição
  String getThemeModeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  /// Retorna ícone do modo atual
  IconData getThemeModeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}