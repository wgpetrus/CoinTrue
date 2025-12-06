

/// Interface para gerenciamento de preferências do usuário
abstract class PreferencesService {
  /// Salva a preferência de biometria ativada
  Future<void> saveBiometricEnabled(bool enabled);

  /// Verifica se a biometria está ativada
  Future<bool> isBiometricEnabled();

  /// Limpa todas as preferências
  Future<void> clear();

  /// Salva o ID do usuário associado à biometria
  Future<void> saveUserId(String userId);

  /// Recupera o ID do usuário associado à biometria
  Future<String?> getUserId();

  /// Remove o ID do usuário
  Future<void> removeUserId();

  /// Salva a preferência de tema (para futuro dark mode)
  Future<void> saveThemeMode(String themeMode);

  /// Recupera a preferência de tema
  Future<String?> getThemeMode();

  /// Salva a preferência de idioma (para futuro i18n)
  Future<void> saveLanguage(String language);

  /// Recupera a preferência de idioma
  Future<String?> getLanguage();
}
