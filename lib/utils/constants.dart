import 'package:flutter/material.dart';

/// Constantes da aplicação
/// Contém cores, strings de UI e configurações gerais
class AppConstants {
  // Previne instanciação
  AppConstants._();

  /// Cores do aplicativo CoinTrue
  static const AppColors colors = AppColors._();

  /// Strings de UI
  static const AppStrings strings = AppStrings._();

  /// Configurações gerais
  static const AppConfig config = AppConfig._();
}

/// Paleta de cores da aplicação
class AppColors {
  const AppColors._();

  // Cores principais
  /// Cor branca - Backgrounds (light mode)
  final Color white = const Color(0xFFFFFFFF);

  /// Cor cinza escuro - Textos primários e títulos
  final Color darkGray = const Color(0xFF545454);

  /// Cor cinza médio - Textos secundários e subtítulos
  final Color mediumGray = const Color(0xFF9E9E9E);

  /// Cor cinza claro - Backgrounds de cards e containers
  final Color lightGray = const Color(0xFFF5F5F5);

  /// Cor cinza muito claro - Borders e dividers
  final Color veryLightGray = const Color(0xFFF0F0F0);

  /// Cor azul primária - Botões primários e fundos
  final Color primary = const Color(0xFF2563EB);

  /// Cor azul escura - Para ícones e textos em fundo branco (melhor contraste)
  final Color primaryDark = const Color(0xFF1E40AF);

  /// Cor roxa secundária - Elementos secundários e gradientes
  final Color secondary = const Color(0xFF7C3AED);

  // Cores de status
  /// Cor para estados de erro e valores negativos
  final Color error = const Color(0xFFF44336);

  /// Cor para estados de sucesso e valores positivos
  final Color success = const Color(0xFF4CAF50);

  /// Cor para informações e elementos secundários
  final Color info = const Color(0xFF2196F3);

  // Cores de criptomoedas
  /// Bitcoin - Laranja
  final Color bitcoin = const Color(0xFFFF9800);

  /// Ethereum - Roxo
  final Color ethereum = const Color(0xFF9C27B0);

  /// Cardano - Azul
  final Color cardano = const Color(0xFF2196F3);

  /// Solana - Rosa/Magenta
  final Color solana = const Color(0xFFE91E63);

  // Utilitários
  /// Cor para loading/overlay
  final Color overlay = const Color(0x80000000);
}

/// Strings de UI da aplicação
class AppStrings {
  const AppStrings._();

  // Tela de Login
  final String welcomeTitle = 'Bem-vindo';
  final String welcomeSubtitle = 'Faça login para continuar';
  final String continueWithGoogle = 'Continuar com Google';
  final String continueWithApple = 'Continuar com Apple';
  final String loginWithBiometric = 'Entrar com Biometria';

  // Biometria
  final String biometricSetupTitle = 'Ativar Biometria';
  final String biometricSetupDescription =
      'Use sua impressão digital ou Face ID para acessar sua conta de forma rápida e segura';
  final String enableBiometric = 'Ativar Biometria';
  final String skipBiometric = 'Agora Não';
  final String biometricReason = 'Autentique-se para fazer login';

  // Mensagens de Erro
  final String errorNetwork = 'Verifique sua conexão com a internet';
  final String errorInvalidCredentials = 'Credenciais inválidas';
  final String errorServiceUnavailable =
      'Serviço temporariamente indisponível. Tente novamente mais tarde';
  final String errorTimeout = 'A operação demorou muito. Tente novamente';
  final String errorGeneric = 'Ocorreu um erro inesperado. Tente novamente';
  final String errorBiometricNotAvailable =
      'Biometria não disponível neste dispositivo';
  final String errorBiometricNotEnrolled =
      'Configure a biometria nas configurações do seu dispositivo';
  final String errorBiometricFailed =
      'Falha na autenticação biométrica. Tente novamente';
  final String errorBiometricMaxAttempts =
      'Muitas tentativas falhadas. Use login manual';

  // Validação
  final String errorInvalidEmail = 'Email em formato inválido';
  final String errorEmptyField = 'Este campo é obrigatório';

  // Loading
  final String processing = 'Processando...';
  final String pleaseWait = 'Por favor, aguarde';

  // Botões
  final String retry = 'Tentar Novamente';
  final String cancel = 'Cancelar';
  final String confirm = 'Confirmar';
}

/// Configurações gerais da aplicação
class AppConfig {
  const AppConfig._();

  /// Timeout padrão para requisições (em segundos)
  final int requestTimeout = 30;

  /// Número máximo de tentativas de login antes de aplicar delay
  final int maxLoginAttempts = 3;

  /// Número máximo de tentativas de biometria
  final int maxBiometricAttempts = 3;

  /// Tempo mínimo para exibir mensagem de processamento (em segundos)
  final int minProcessingTime = 3;

  /// Delays progressivos para tentativas de login (em segundos)
  final List<int> loginDelays = const [1, 2, 4, 8, 16];

  /// Versão mínima do Android suportada
  final int minAndroidSdk = 23;
}

/// Caminhos de assets
class AppAssets {
  AppAssets._();

  static const String logoApp = 'assets/images/logos/logo_app.png';
  static const String logoGoogle = 'assets/images/logos/logo_google.png';
  static const String logoApple = 'assets/images/logos/logo_apple.png';
  static const String logoBiometric = 'assets/images/logos/logo_biometric.png';
}
