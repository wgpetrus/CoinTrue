import 'package:flutter/material.dart';

/// Constantes da aplicação
/// Contém cores, strings de UI e configurações gerais
class AppConstants {
  // Previne instanciação
  AppConstants._();

  /// Cores do aplicativo CoinTrue (Light Mode)
  static const AppColors colors = AppColors.light;

  /// Strings de UI
  static const AppStrings strings = AppStrings._();

  /// Configurações gerais
  static const AppConfig config = AppConfig._();
}

/// Paleta de cores da aplicação com suporte a Light/Dark Mode
class AppColors {
  final bool isDark;
  
  const AppColors._(this.isDark);
  
  // Factory constructors para light e dark mode
  static const AppColors light = AppColors._(false);
  static const AppColors dark = AppColors._(true);

  // Cores principais adaptáveis
  /// Background principal da aplicação
  Color get background => isDark 
    ? const Color(0xFF0F0F0F)  // Preto quase puro (melhor para OLED)
    : const Color(0xFFFFFFFF); // Branco

  /// Background de cards e containers
  Color get surface => isDark 
    ? const Color(0xFF1A1A1A)  // Cinza escuro com bom contraste
    : const Color(0xFFF5F5F5); // Cinza claro

  /// Background de cards elevados
  Color get surfaceElevated => isDark 
    ? const Color(0xFF242424)  // Cinza mais claro para elevação
    : const Color(0xFFFFFFFF); // Branco

  /// Texto primário (títulos, conteúdo principal)
  Color get onBackground => isDark 
    ? const Color(0xFFE8E8E8)  // Branco suave (melhor que branco puro)
    : const Color(0xFF1A1A1A); // Preto suave

  /// Texto secundário (subtítulos, descrições)
  Color get onSurface => isDark 
    ? const Color(0xFFB0B0B0)  // Cinza claro com bom contraste
    : const Color(0xFF6B6B6B); // Cinza médio

  /// Texto terciário (labels, placeholders)
  Color get onSurfaceVariant => isDark 
    ? const Color(0xFF8A8A8A)  // Cinza médio
    : const Color(0xFF9E9E9E); // Cinza médio

  /// Borders e dividers
  Color get outline => isDark 
    ? const Color(0xFF2F2F2F)  // Cinza escuro sutil
    : const Color(0xFFE0E0E0); // Cinza claro

  /// Borders mais sutis
  Color get outlineVariant => isDark 
    ? const Color(0xFF1F1F1F)  // Cinza muito escuro
    : const Color(0xFFF0F0F0); // Cinza muito claro

  // Cores de marca (sempre as mesmas)
  /// Cor azul primária - Botões primários e fundos
  Color get primary => const Color(0xFF2563EB);

  /// Cor azul escura - Para ícones e textos em fundo branco
  Color get primaryDark => const Color(0xFF1E40AF);

  /// Cor roxa secundária - Elementos secundários e gradientes
  Color get secondary => const Color(0xFF7C3AED);

  /// Texto sobre cor primária
  Color get onPrimary => const Color(0xFFFFFFFF);

  // Cores de status (ajustadas para dark mode)
  /// Cor para estados de erro e valores negativos
  Color get error => isDark 
    ? const Color(0xFFFF6B6B)  // Vermelho mais suave no dark
    : const Color(0xFFF44336); // Vermelho padrão

  /// Cor para estados de sucesso e valores positivos
  Color get success => isDark 
    ? const Color(0xFF4ECDC4)  // Verde mais suave no dark
    : const Color(0xFF4CAF50); // Verde padrão

  /// Cor para informações e elementos secundários
  Color get info => isDark 
    ? const Color(0xFF45B7D1)  // Azul mais suave no dark
    : const Color(0xFF2196F3); // Azul padrão

  /// Cor de aviso
  Color get warning => isDark 
    ? const Color(0xFFFFD93D)  // Amarelo mais suave no dark
    : const Color(0xFFFF9800); // Laranja padrão

  // Cores de criptomoedas (sempre as mesmas)
  /// Bitcoin - Laranja
  Color get bitcoin => const Color(0xFFFF9800);

  /// Ethereum - Roxo
  Color get ethereum => const Color(0xFF9C27B0);

  /// Cardano - Azul
  Color get cardano => const Color(0xFF2196F3);

  /// Solana - Rosa/Magenta
  Color get solana => const Color(0xFFE91E63);

  // Utilitários
  /// Cor para loading/overlay
  Color get overlay => isDark 
    ? const Color(0xCC000000)  // Overlay mais escuro
    : const Color(0x80000000); // Overlay padrão

  /// Cor para sombras
  Color get shadow => isDark 
    ? const Color(0x40000000)  // Sombra mais sutil no dark
    : const Color(0x1A000000); // Sombra padrão

  // Cores especiais para gradientes
  /// Gradiente primário (início)
  Color get gradientStart => primary;

  /// Gradiente primário (fim)
  Color get gradientEnd => secondary;

  // Compatibilidade com código existente
  Color get white => background;
  Color get darkGray => onBackground;
  Color get mediumGray => onSurface;
  Color get lightGray => surface;
  Color get veryLightGray => outline;
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
