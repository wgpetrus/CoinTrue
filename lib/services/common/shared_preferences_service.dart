import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_service.dart';

/// Implementação de PreferencesService usando SharedPreferences
class SharedPreferencesService implements PreferencesService {
  // Chaves para armazenamento
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyUserId = 'user_id';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';

  // Instância singleton
  static SharedPreferencesService? _instance;
  SharedPreferences? _prefs;

  // Construtor privado para singleton
  SharedPreferencesService._();

  /// Retorna a instância singleton do serviço
  static Future<SharedPreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Inicializa o SharedPreferences
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Garante que o SharedPreferences está inicializado
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await _init();
    }
    return _prefs!;
  }

  @override
  Future<void> saveBiometricEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  @override
  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  @override
  Future<void> saveUserId(String userId) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyUserId, userId);
  }

  @override
  Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserId);
  }

  @override
  Future<void> removeUserId() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyUserId);
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyThemeMode, themeMode);
  }

  @override
  Future<String?> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyThemeMode);
  }

  @override
  Future<void> saveLanguage(String language) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyLanguage, language);
  }

  @override
  Future<String?> getLanguage() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyLanguage);
  }
}
